package com.tripan.app.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.tripan.app.domain.dto.PlaceDto;
import com.tripan.app.domain.dto.TripPlaceDto;
import com.tripan.app.mapper.PlaceMapper;
import com.tripan.app.mapper.PlaceRecommendMapper;
import com.tripan.app.mapper.TripPlaceMapper;
import com.tripan.app.service.PlaceService;
import com.tripan.app.service.TripPlaceService;

import jakarta.servlet.http.HttpSession;
import com.tripan.app.service.TourApiSyncService;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/places")
@RequiredArgsConstructor
public class TripPlaceApiController {

    // [Track 1] KTO 마스터 장소
    private final PlaceService  placeService;
    private final PlaceMapper   placeMapper;

    // [Track 1-B] 큐레이션 목록/상세 전용 매퍼 (place_list.js, place_detail.js)
    private final PlaceRecommendMapper placeRecommendMapper;

    // [Track 2] 나만의 장소 (카카오맵)
    private final TripPlaceService tripPlaceService;
    private final TripPlaceMapper  tripPlaceMapper;

    // [Track 3] TourAPI 동기화 서비스 (식당 상세 실시간 조회)
    private final TourApiSyncService tourApiSyncService;

    // ─────────────────────────────────────────────────────────────
    // [큐레이션 목록] 이미지 있는 장소만 – place_list.js 전용
    // ─────────────────────────────────────────────────────────────
    @GetMapping("/curation")
    public ResponseEntity<Map<String, Object>> curation(
            @RequestParam(value = "category", defaultValue = "전체") String category,
            @RequestParam(value = "region",   defaultValue = "전체") String region,
            @RequestParam(value = "keyword",  defaultValue = "")    String keyword,
            @RequestParam(value = "limit",    defaultValue = "12")  int    limit,
            @RequestParam(value = "offset",   defaultValue = "0")   int    offset,
            @RequestParam(value = "sort",     defaultValue = "recent") String sort) {

        List<PlaceDto> places = placeRecommendMapper.selectCurationPlaces(
                category, region, keyword, limit, offset, sort);
        long total = placeRecommendMapper.countCurationPlaces(category, region, keyword);

        Map<String, Object> body = new HashMap<>();
        body.put("places",  places);
        body.put("total",   total);
        body.put("hasMore", (offset + limit) < total);

        return ResponseEntity.ok(body);
    }

    // ─────────────────────────────────────────────────────────────
    // [큐레이션] 카테고리 + 지역 + 키워드 추천 목록
    // ─────────────────────────────────────────────────────────────
    @GetMapping("/recommend")
    public ResponseEntity<Map<String, Object>> recommend(
            @RequestParam(value = "category", defaultValue = "전체") String category,
            @RequestParam(value = "region",   defaultValue = "전체") String region,
            @RequestParam(value = "keyword",  defaultValue = "")    String keyword,
            @RequestParam(value = "limit",    defaultValue = "12")  int    limit,
            @RequestParam(value = "offset",   defaultValue = "0")   int    offset) {

        List<PlaceDto> places = placeRecommendMapper.selectRecommendPlaces(
                category, region, keyword, limit, offset);
        long total = placeRecommendMapper.countRecommendPlaces(category, region, keyword);

        Map<String, Object> body = new HashMap<>();
        body.put("places",  places);
        body.put("total",   total);
        body.put("hasMore", (offset + limit) < total);

        return ResponseEntity.ok(body);
    }

    // ─────────────────────────────────────────────────────────────
    // [큐레이션] 주변 장소
    // ─────────────────────────────────────────────────────────────
    @GetMapping("/{placeId}/nearby")
    public ResponseEntity<List<PlaceDto>> nearby(@PathVariable Long placeId) {
        PlaceDto place = placeRecommendMapper.selectPlaceLatLng(placeId);
        if (place == null
                || place.getLatitude()  == null
                || place.getLongitude() == null) {
            return ResponseEntity.ok(List.of());
        }
        List<PlaceDto> nearbyList = placeRecommendMapper.selectNearbyPlaces(
                placeId,
                place.getLatitude(),
                place.getLongitude(),
                5);
        return ResponseEntity.ok(nearbyList);
    }

    // ─────────────────────────────────────────────────────────────
    // [통합] 키워드 검색
    // ─────────────────────────────────────────────────────────────
    @GetMapping("/search")
    public ResponseEntity<Map<String, Object>> search(
            @RequestParam("keyword") String keyword,
            @RequestParam(value = "category", defaultValue = "all") String category,
            HttpSession session) {

        Long memberId = getLoginMemberId(session);

        List<PlaceDto> officialPlaces = placeMapper.searchPlacesByName(keyword, category);

        List<TripPlaceDto> myPlaces = (memberId != null)
            ? tripPlaceService.searchPlaces(keyword, memberId)
            : List.of();

        Map<String, Object> body = new HashMap<>();
        body.put("officialPlaces", officialPlaces);
        body.put("myPlaces",       myPlaces);

        return ResponseEntity.ok(body);
    }

    // ─────────────────────────────────────────────────────────────
    // [나만의 장소] 목록
    // ─────────────────────────────────────────────────────────────
    @GetMapping("/my")
    public ResponseEntity<?> myPlaces(HttpSession session) {
        Long memberId = getLoginMemberId(session);
        if (memberId == null)
            return ResponseEntity.status(401)
                .body(Map.of("success", false, "message", "로그인이 필요합니다"));
        return ResponseEntity.ok(tripPlaceService.getMyPlaces(memberId));
    }

    // ─────────────────────────────────────────────────────────────
    // [나만의 장소] 등록 (NONE 카테고리 — member_id = 로그인 유저)
    // ─────────────────────────────────────────────────────────────
    @PostMapping("/my")
    public ResponseEntity<?> registerMyPlace(
            @RequestBody TripPlaceDto dto,
            HttpSession session) {

        Long memberId = getLoginMemberId(session);
        if (memberId == null)
            return ResponseEntity.status(401)
                .body(Map.of("success", false, "message", "로그인이 필요합니다"));
        if (dto.getPlaceName() == null || dto.getPlaceName().isBlank())
            return ResponseEntity.badRequest()
                .body(Map.of("success", false, "message", "장소명은 필수입니다"));

        TripPlaceDto saved = tripPlaceService.registerMyPlace(dto, memberId);
        return ResponseEntity.ok(Map.of("success", true, "place", saved));
    }

    // ─────────────────────────────────────────────────────────────
    // ★ [공용 장소] find-or-create (비-NONE 카테고리 — member_id = NULL)
    //
    // BUG FIX: 지도 검색 결과에서 비-NONE 카테고리(RESTAURANT 등) 장소를 추가할 때
    //   kakaoId 가 없으면 기존에 addPlaceToDay 를 kakaoId=null 로 호출하여
    //   백엔드가 기존 레코드를 찾지 못해 member_id=null 복제본을 계속 삽입하는 버그 수정.
    //
    //   이 엔드포인트가 항상 apiContentId 를 채운 TripPlaceDto 를 반환하면
    //   workspace_map.js 의 executeMapAdd() 가 그 apiContentId 를 addPlaceToDay 에 전달해
    //   백엔드가 기존 레코드를 정확히 재사용함 → 중복 삽입 방지
    // ─────────────────────────────────────────────────────────────
    @PostMapping("/findOrCreate")
    public ResponseEntity<?> findOrCreatePublicPlace(
            @RequestBody TripPlaceDto dto) {

        if (dto.getPlaceName() == null || dto.getPlaceName().isBlank())
            return ResponseEntity.badRequest()
                .body(Map.of("success", false, "message", "장소명은 필수입니다"));

        TripPlaceDto saved = tripPlaceService.findOrCreatePublicPlace(dto);
        return ResponseEntity.ok(Map.of("success", true, "place", saved));
    }

    // ─────────────────────────────────────────────────────────────
    // [나만의 장소] 삭제
    // ─────────────────────────────────────────────────────────────
    @DeleteMapping("/my/{placeId}")
    public ResponseEntity<?> deleteMyPlace(
            @PathVariable("placeId") Long placeId,
            HttpSession session) {

        Long memberId = getLoginMemberId(session);
        if (memberId == null)
            return ResponseEntity.status(401)
                .body(Map.of("success", false, "message", "로그인이 필요합니다"));

        boolean deleted = tripPlaceService.deleteMyPlace(placeId, memberId);
        if (deleted)
            return ResponseEntity.ok(Map.of("success", true));
        else
            return ResponseEntity.status(403)
                .body(Map.of("success", false,
                    "message", "삭제 권한이 없거나 존재하지 않는 장소입니다"));
    }

    // ─────────────────────────────────────────────────────────────
    // [식당] 상세 정보 실시간 조회 (TourAPI detailIntro2)
    // ─────────────────────────────────────────────────────────────
    @GetMapping("/restaurant-detail/{contentId}")
    public ResponseEntity<Map<String, Object>> restaurantDetail(
            @PathVariable("contentId") String contentId) {

        if (contentId == null || contentId.startsWith("custom_")) {
            return ResponseEntity.ok(new HashMap<>());
        }

        Map<String, Object> detail = tourApiSyncService.getRestaurantDetail(contentId);
        return ResponseEntity.ok(detail);
    }

    // ─────────────────────────────────────────────────────────────
    // [식당] 로컬 DB 상세 조회 (프론트 모달)
    // ─────────────────────────────────────────────────────────────
    @GetMapping("/restaurant/{placeId}")
    public ResponseEntity<Map<String, Object>> getLocalRestaurantDetail(
            @PathVariable("placeId") Long placeId) {

        Map<String, Object> detail = placeMapper.getRestaurantDetailByPlaceId(placeId);
        if (detail == null) {
            return ResponseEntity.ok(new HashMap<>());
        }
        return ResponseEntity.ok(detail);
    }

    // ─────────────────────────────────────────────────────────────
    // [관광지/문화/레포츠] 로컬 DB 상세 (attraction 테이블)
    // ─────────────────────────────────────────────────────────────
    @GetMapping("/attraction/{placeId}")
    public ResponseEntity<Map<String, Object>> getAttractionDetail(
            @PathVariable("placeId") Long placeId) {

        Map<String, Object> detail = placeMapper.getAttractionDetailByPlaceId(placeId);
        if (detail == null) return ResponseEntity.ok(new HashMap<>());
        return ResponseEntity.ok(detail);
    }

    // ─────────────────────────────────────────────────────────────
    // [KTO] 배치 수동 트리거
    // ─────────────────────────────────────────────────────────────
    @PostMapping("/sync")
    public ResponseEntity<Map<String, Object>> syncBatch() {
        placeService.syncPlacesBatch();
        return ResponseEntity.ok(Map.of("success", true, "message", "KTO 동기화 완료"));
    }

    // ─────────────────────────────────────────────────────────────
    private Long getLoginMemberId(HttpSession session) {
        Object user = session.getAttribute("loginUser");
        if (user == null) return null;
        try {
            return (Long) user.getClass().getMethod("getMemberId").invoke(user);
        } catch (Exception e) {
            return null;
        }
    }
}