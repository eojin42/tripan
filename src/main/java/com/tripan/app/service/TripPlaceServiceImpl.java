package com.tripan.app.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.tripan.app.domain.dto.TripPlaceDto;
import com.tripan.app.mapper.PlaceMapper;
import com.tripan.app.mapper.TripPlaceMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;

import java.util.List;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class TripPlaceServiceImpl implements TripPlaceService {

    private final TripPlaceMapper tripPlaceMapper;
    private final PlaceMapper placeMapper;

    @Value("${tripan.api.kakao-map-api-key}")
    private String kakaoRestApiKey;

    // ── 키워드 검색 ────────────────────────────────────────────────
    @Override
    @Transactional
    public List<TripPlaceDto> searchPlaces(String keyword, Long currentMemberId) {
        fetchAndSaveFromKakao(keyword);
        return tripPlaceMapper.searchPlacesByKeyword(keyword, currentMemberId);
    }

    private void fetchAndSaveFromKakao(String keyword) {
        try {
            RestTemplate restTemplate = new RestTemplate();
            HttpHeaders headers = new HttpHeaders();
            headers.set("Authorization", "KakaoAK " + kakaoRestApiKey);
            HttpEntity<String> entity = new HttpEntity<>(headers);

            String url = "https://dapi.kakao.com/v2/local/search/keyword.json?query=" + keyword;
            ResponseEntity<String> response = restTemplate.exchange(url, HttpMethod.GET, entity, String.class);

            ObjectMapper objectMapper = new ObjectMapper();
            JsonNode documents = objectMapper.readTree(response.getBody()).path("documents");

            for (JsonNode doc : documents) {
                String kakaoId   = doc.path("id").asText();
                String placeName = doc.path("place_name").asText();
                String address   = doc.path("address_name").asText();

                if (tripPlaceMapper.findPlaceIdByApiContentId(kakaoId) != null) continue;
                if (placeMapper.findPlaceIdByNameAndAddress(placeName, address) != null) continue;

                TripPlaceDto dto = new TripPlaceDto();
                dto.setMemberId(null);
                dto.setApiContentId(kakaoId);
                dto.setPlaceName(placeName);
                dto.setAddress(address);
                dto.setLatitude(doc.path("y").asDouble());
                dto.setLongitude(doc.path("x").asDouble());
                dto.setCategory(doc.path("category_group_name").asText());
                dto.setImageUrl(doc.path("place_url").asText());

                tripPlaceMapper.insertPlace(dto);
            }
        } catch (Exception e) {
            log.error("카카오 API 검색 및 저장 중 오류 발생: {}", e.getMessage());
        }
    }

    // ── 나만의 장소 직접 등록 ──────────────────────────────────────
    // 🐛 BUG FIX: insertPlace() 전 apiContentId(=api_place_id) 반드시 세팅
    //   원인: api_place_id NOT NULL 컬럼인데 값을 세팅하지 않아 ORA-01400 발생
    @Override
    @Transactional
    public TripPlaceDto registerMyPlace(TripPlaceDto dto, Long memberId) {
        dto.setMemberId(memberId);
        dto.setContentTypeId(null);

        if (dto.getCategory() == null || dto.getCategory().isBlank()) {
            dto.setCategory("NONE");
        }

        // ✅ FIX: 서버에서 고유 custom_UUID 생성 → api_place_id NULL 방지
        dto.setApiContentId("custom_" + UUID.randomUUID().toString().replace("-", ""));

        tripPlaceMapper.insertPlace(dto);
        return dto;
    }

    // ── 나만의 장소 삭제 (본인 소유 검증) ─────────────────────────
    @Override
    @Transactional
    public boolean deleteMyPlace(Long placeId, Long memberId) {
        int deleted = tripPlaceMapper.deleteMyPlace(placeId, memberId);
        return deleted > 0;
    }

    // ── 나만의 장소 목록 ───────────────────────────────────────────
    @Override
    public List<TripPlaceDto> getMyPlaces(Long memberId) {
        return tripPlaceMapper.selectMyPlaces(memberId);
    }
}
