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

import org.springframework.dao.DuplicateKeyException;

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

    // ── 나만의 장소 직접 등록 ────────────────────────
    @Override
    @Transactional
    public TripPlaceDto registerMyPlace(TripPlaceDto dto, Long memberId) {
        dto.setMemberId(memberId);
        dto.setContentTypeId(null);

        if (dto.getCategory() == null || dto.getCategory().isBlank()) {
            dto.setCategory("NONE");
        }

        // name+address 중복 체크
        if (dto.getPlaceName() != null && dto.getAddress() != null) {
            TripPlaceDto existing = tripPlaceMapper.selectPlaceByNameAndAddress(
                    dto.getPlaceName(), dto.getAddress(), memberId);
            if (existing != null) {
                log.debug("나만의 장소 중복(name+address) - 기존 반환: placeId={}", existing.getPlaceId());
                return existing;
            }
        }

        // lat/lng 중복 체크 (주소 표기가 달라도 같은 좌표면 중복)
        if (dto.getLatitude() != null && dto.getLongitude() != null) {
            Long existingId = tripPlaceMapper.findPlaceIdByLatLng(
                    dto.getLatitude(), dto.getLongitude(), memberId);
            if (existingId != null) {
                log.debug("나만의 장소 중복(lat/lng) - 기존 반환: placeId={}", existingId);
                return tripPlaceMapper.selectPlaceById(existingId, memberId);
            }
        }

        // INSERT — race condition 대비 DuplicateKeyException catch
        dto.setApiContentId("custom_" + UUID.randomUUID().toString().replace("-", ""));
        try {
            tripPlaceMapper.insertPlace(dto);
        } catch (DuplicateKeyException e) {
            // 동시 요청으로 인해 이미 삽입된 경우 → 기존 레코드 재조회 후 반환
            log.warn("나만의 장소 동시 삽입 충돌(race condition) - 기존 레코드 조회: name={}", dto.getPlaceName());
            TripPlaceDto existing = tripPlaceMapper.selectPlaceByNameAndAddress(
                    dto.getPlaceName(), dto.getAddress(), memberId);
            if (existing != null) return existing;

            Long existingId = tripPlaceMapper.findPlaceIdByLatLng(
                    dto.getLatitude(), dto.getLongitude(), memberId);
            if (existingId != null) return tripPlaceMapper.selectPlaceById(existingId, memberId);

            throw e; 
        }
        return dto;
    }


    @Override
    @Transactional
    public TripPlaceDto findOrCreatePublicPlace(TripPlaceDto dto) {

        // kakaoId(apiContentId) 로 조회
        if (dto.getApiContentId() != null && !dto.getApiContentId().isBlank()) {
            TripPlaceDto existing = tripPlaceMapper.selectPlaceByApiContentId(dto.getApiContentId());
            if (existing != null) {
                log.debug("공용 장소 기존 레코드 반환(by apiContentId): {}", existing.getApiContentId());
                return existing;
            }
        }

        //  name+address 로 조회 (memberId=null → 공용 레코드만 검색)
        if (dto.getPlaceName() != null && dto.getAddress() != null) {
            TripPlaceDto existing = tripPlaceMapper.selectPlaceByNameAndAddress(
                    dto.getPlaceName(), dto.getAddress(), null);
            if (existing != null) {
                log.debug("공용 장소 기존 레코드 반환(by name+address): id={}, apiContentId={}",
                        existing.getPlaceId(), existing.getApiContentId());
                return existing;
            }
        }

        // 신규 삽입 — member_id=NULL, apiContentId 가 없으면 임시 ID 생성
        dto.setMemberId(null);
        if (dto.getApiContentId() == null || dto.getApiContentId().isBlank()) {
            // kakaoId 가 없는 경우 name+address 기반 결정론적 ID 생성
            String seed = (dto.getPlaceName() + "|" + dto.getAddress()).replaceAll("\\s", "");
            dto.setApiContentId("place_" + Integer.toHexString(seed.hashCode())
                    + "_" + UUID.randomUUID().toString().replace("-", "").substring(0, 8));
        }
        if (dto.getCategory() == null || dto.getCategory().isBlank()) {
            dto.setCategory("ETC");
        }

        tripPlaceMapper.insertPlace(dto);
        log.debug("공용 장소 신규 삽입: placeId={}, apiContentId={}", dto.getPlaceId(), dto.getApiContentId());
        return dto;
    }

    // ── 나만의 장소 삭제 (본인 소유 검증 + 자식 레코드 cascade) ─────────────────────────
    @Override
    @Transactional
    public boolean deleteMyPlace(Long placeId, Long memberId) {
        //  해당 장소를 참조하는 itinerary_item 의 이미지 삭제
        tripPlaceMapper.deleteItineraryImagesByPlaceId(placeId);
        //  해당 장소를 참조하는 itinerary_item 삭제
        tripPlaceMapper.deleteItineraryItemsByPlaceId(placeId);
        //  trip_place 본체 삭제 (본인 소유 검증)
        int deleted = tripPlaceMapper.deleteMyPlace(placeId, memberId);
        return deleted > 0;
    }

    // ── 나만의 장소 목록 ───────────────────────────────────────────
    @Override
    public List<TripPlaceDto> getMyPlaces(Long memberId) {
        return tripPlaceMapper.selectMyPlaces(memberId);
    }
}