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

    // ── 나만의 장소 직접 등록 (NONE 카테고리) ────────────────────────
    // 중복 방지 3단계:
    //   1. name+address 로 기존 레코드 조회
    //   2. lat/lng 로 기존 레코드 조회 (주소가 다르게 입력된 경우 방어)
    //   3. INSERT 시 DuplicateKeyException → race condition 방어 (동시 요청)
    @Override
    @Transactional
    public TripPlaceDto registerMyPlace(TripPlaceDto dto, Long memberId) {
        dto.setMemberId(memberId);
        dto.setContentTypeId(null);

        if (dto.getCategory() == null || dto.getCategory().isBlank()) {
            dto.setCategory("NONE");
        }

        // ✅ 1단계: name+address 중복 체크
        if (dto.getPlaceName() != null && dto.getAddress() != null) {
            TripPlaceDto existing = tripPlaceMapper.selectPlaceByNameAndAddress(
                    dto.getPlaceName(), dto.getAddress(), memberId);
            if (existing != null) {
                log.debug("나만의 장소 중복(name+address) - 기존 반환: placeId={}", existing.getPlaceId());
                return existing;
            }
        }

        // ✅ 2단계: lat/lng 중복 체크 (주소 표기가 달라도 같은 좌표면 중복)
        if (dto.getLatitude() != null && dto.getLongitude() != null) {
            Long existingId = tripPlaceMapper.findPlaceIdByLatLng(
                    dto.getLatitude(), dto.getLongitude(), memberId);
            if (existingId != null) {
                log.debug("나만의 장소 중복(lat/lng) - 기존 반환: placeId={}", existingId);
                return tripPlaceMapper.selectPlaceById(existingId, memberId);
            }
        }

        // ✅ 3단계: INSERT — race condition 대비 DuplicateKeyException catch
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

            throw e; // 진짜 다른 이유의 중복키 에러면 재throw
        }
        return dto;
    }

    // ── 공용 장소 find-or-create (RESTAURANT·TOUR 등 비-NONE 카테고리) ──
    // ★ BUG FIX: kakaoId 없을 때 addPlaceToDay 를 그냥 호출하면
    //    백엔드가 기존 레코드(예: id=381)를 api_place_id="381" 로 재사용하지 않고
    //    새 레코드(407, 408…)를 중복 삽입하는 버그 수정
    //
    // 처리 순서:
    //   ① apiContentId(kakaoId) 로 기존 레코드 조회
    //   ② 없으면 name+address 로 조회 (apiContentId 무관)
    //   ③ 없으면 member_id=NULL 공용 레코드 신규 삽입
    //   ④ 항상 apiContentId 를 채운 DTO 반환
    @Override
    @Transactional
    public TripPlaceDto findOrCreatePublicPlace(TripPlaceDto dto) {

        // ① kakaoId(apiContentId) 로 조회
        if (dto.getApiContentId() != null && !dto.getApiContentId().isBlank()) {
            TripPlaceDto existing = tripPlaceMapper.selectPlaceByApiContentId(dto.getApiContentId());
            if (existing != null) {
                log.debug("공용 장소 기존 레코드 반환(by apiContentId): {}", existing.getApiContentId());
                return existing;
            }
        }

        // ② name+address 로 조회 (memberId=null → 공용 레코드만 검색)
        if (dto.getPlaceName() != null && dto.getAddress() != null) {
            TripPlaceDto existing = tripPlaceMapper.selectPlaceByNameAndAddress(
                    dto.getPlaceName(), dto.getAddress(), null);
            if (existing != null) {
                log.debug("공용 장소 기존 레코드 반환(by name+address): id={}, apiContentId={}",
                        existing.getPlaceId(), existing.getApiContentId());
                return existing;
            }
        }

        // ③ 신규 삽입 — member_id=NULL, apiContentId 가 없으면 임시 ID 생성
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
    // ORA-02292(FK_ITEM_PLACE) 방지:
    //   itinerary_image → itinerary_item → trip_place 순서로 삭제
    @Override
    @Transactional
    public boolean deleteMyPlace(Long placeId, Long memberId) {
        // Step 1: 해당 장소를 참조하는 itinerary_item 의 이미지 삭제
        tripPlaceMapper.deleteItineraryImagesByPlaceId(placeId);
        // Step 2: 해당 장소를 참조하는 itinerary_item 삭제
        tripPlaceMapper.deleteItineraryItemsByPlaceId(placeId);
        // Step 3: trip_place 본체 삭제 (본인 소유 검증)
        int deleted = tripPlaceMapper.deleteMyPlace(placeId, memberId);
        return deleted > 0;
    }

    // ── 나만의 장소 목록 ───────────────────────────────────────────
    @Override
    public List<TripPlaceDto> getMyPlaces(Long memberId) {
        return tripPlaceMapper.selectMyPlaces(memberId);
    }
}