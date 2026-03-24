package com.tripan.app.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.tripan.app.domain.dto.PlaceDto;
import com.tripan.app.domain.dto.TripPlaceDto;
import com.tripan.app.mapper.PlaceMapper;
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

    // [Track 2] 나만의 장소 (카카오맵)
    private final TripPlaceService tripPlaceService;
    private final TripPlaceMapper  tripPlaceMapper;

    // [Track 3] TourAPI 동기화 서비스 (식당 상세 실시간 조회)
    private final TourApiSyncService tourApiSyncService;

    // ── [KTO] 카테고리별 추천 (무한스크롤 offset 지원) ───────────
    // GET /api/places/recommend?category=RESTAURANT&city=부산,제주&limit=12&offset=0
    @GetMapping("/recommend")
    public ResponseEntity<Map<String, Object>> recommend(
            @RequestParam(value = "category", defaultValue = "all") String category,
            @RequestParam(value = "city",     defaultValue = "")    String city,
            @RequestParam(value = "limit",    defaultValue = "12")  int    limit,
            @RequestParam(value = "offset",   defaultValue = "0")   int    offset) {

        // "부산,제주" → ["부산", "제주"] — 다중 도시 지원
        List<String> cityList = city.isBlank()
            ? List.of()
            : List.of(city.split(","));

        List<PlaceDto> results = placeMapper.selectRecommendPlaces(category, cityList, limit, offset);
        long total             = placeMapper.countRecommendPlaces(category, cityList);

        Map<String, Object> body = new HashMap<>();
        body.put("places",  results);
        body.put("total",   total);
        body.put("offset",  offset);
        body.put("limit",   limit);
        body.put("hasMore", (offset + limit) < total);

        return ResponseEntity.ok(body);
    }

    // ── [통합] 키워드 검색 ────────────────────────────────────────
    // GET /api/places/search?keyword=제주&category=RESTAURANT
    // category 생략 또는 "all" → 전체 검색
    // 반환: { officialPlaces: [...PlaceDto], myPlaces: [...TripPlaceDto] }
    @GetMapping("/search")
    public ResponseEntity<Map<String, Object>> search(
            @RequestParam("keyword") String keyword,
            @RequestParam(value = "category", defaultValue = "all") String category,
            HttpSession session) {

        Long memberId = getLoginMemberId(session);

        // KTO 공식 장소 검색 (place 테이블) - category 필터 포함
        List<PlaceDto> officialPlaces = placeMapper.searchPlacesByName(keyword, category);

        // 나만의 장소 검색 (trip_place 테이블, 로그인 시만)
        List<TripPlaceDto> myPlaces = (memberId != null)
            ? tripPlaceService.searchPlaces(keyword, memberId)
            : List.of();

        Map<String, Object> body = new HashMap<>();
        body.put("officialPlaces", officialPlaces);
        body.put("myPlaces",       myPlaces);

        return ResponseEntity.ok(body);
    }

    // ── [나만의 장소] 목록 ─────────────────────────────────────────
    @GetMapping("/my")
    public ResponseEntity<?> myPlaces(HttpSession session) {
        Long memberId = getLoginMemberId(session);
        if (memberId == null)
            return ResponseEntity.status(401)
                .body(Map.of("success", false, "message", "로그인이 필요합니다"));
        return ResponseEntity.ok(tripPlaceService.getMyPlaces(memberId));
    }

    // ── [나만의 장소] 등록 ─────────────────────────────────────────
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
    
    // ── [나만의 장소] 삭제 ──────────────────────────────
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


    // ── [식당] 상세 정보 실시간 조회 (TourAPI detailIntro2) ─────────
    // GET /api/places/restaurant-detail/{contentId}
    @GetMapping("/restaurant-detail/{contentId}")
    public ResponseEntity<Map<String, Object>> restaurantDetail(
            @PathVariable("contentId") String contentId) {

        if (contentId == null || contentId.startsWith("custom_")) {
            return ResponseEntity.ok(new HashMap<>());
        }

        Map<String, Object> detail = tourApiSyncService.getRestaurantDetail(contentId);
        return ResponseEntity.ok(detail);
    }

    // ── [KTO] 배치 수동 트리거 ────────────────────────────────────
    @PostMapping("/sync")
    public ResponseEntity<Map<String, Object>> syncBatch() {
        placeService.syncPlacesBatch();
        return ResponseEntity.ok(Map.of("success", true, "message", "KTO 동기화 완료"));
    }

    // ──────────────────────────────────────────────────────────────
    private Long getLoginMemberId(HttpSession session) {
        Object user = session.getAttribute("loginUser");
        if (user == null) return null;
        try { return (Long) user.getClass().getMethod("getMemberId").invoke(user); }
        catch (Exception e) { return null; }
    }
    
    // [식당 전용 상세 조회 API] 프론트 모달에서 호출함
    @GetMapping("/restaurant/{placeId}")
    public ResponseEntity<Map<String, Object>> getLocalRestaurantDetail(@PathVariable("placeId") Long placeId) {
        Map<String, Object> detail = placeMapper.getRestaurantDetailByPlaceId(placeId);
        if (detail == null) {
            return ResponseEntity.ok(new HashMap<>()); // 없으면 빈 객체 반환
        }
        return ResponseEntity.ok(detail);
    }
}