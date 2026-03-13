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

// 나만의 장소\
@Slf4j
@Service
@RequiredArgsConstructor
public class TripPlaceServiceImpl implements TripPlaceService {

    private final TripPlaceMapper tripPlaceMapper;
    private final PlaceMapper placeMapper;

    // 💡 기존 yml에 등록된 카카오 키값 그대로 사용
    @Value("${tripan.api.kakao-map-api-key}")
    private String kakaoRestApiKey;

    
    // 키워드 검색 
    @Override
    @Transactional
    public List<TripPlaceDto> searchPlaces(String keyword, Long currentMemberId) {
        
        // 카카오 API 검색 -> KTO 중복 검사 -> DB에 저장
        fetchAndSaveFromKakao(keyword);

        // 권한 제어 적용: 공용 장소 + 내 장소만 조회
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
                String kakaoId = doc.path("id").asText();
                String placeName = doc.path("place_name").asText();
                String address = doc.path("address_name").asText();

                if (tripPlaceMapper.findPlaceIdByApiContentId(kakaoId) != null) continue;
                if (placeMapper.findPlaceIdByNameAndAddress(placeName, address) != null) continue;

                TripPlaceDto dto = new TripPlaceDto();
                dto.setMemberId(null); // 공용 장소 처리
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

    // 나만의 장소 직접 등록 
    @Override
    @Transactional
    public TripPlaceDto registerMyPlace(TripPlaceDto dto, Long memberId) {
        Long existing = tripPlaceMapper.findPlaceIdByNameAndAddress(
                dto.getPlaceName(), dto.getAddress());
        
        if (existing != null) {
            dto.setPlaceId(existing);
            return dto;
        }
        
        dto.setMemberId(memberId);   // 소유자 반드시 기록
        dto.setContentTypeId(null);
        if (dto.getCategory() == null || dto.getCategory().isBlank()) {
            dto.setCategory("ETC");
        }
        
        tripPlaceMapper.insertPlace(dto);
        return dto;
    }

    // 나만의 장소 목록 (본인 전용)
    @Override
    public List<TripPlaceDto> getMyPlaces(Long memberId) {
        return tripPlaceMapper.selectMyPlaces(memberId);
    }
}