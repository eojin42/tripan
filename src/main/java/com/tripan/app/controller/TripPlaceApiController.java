package com.tripan.app.controller;

import java.util.List;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.tripan.app.domain.dto.TripPlaceDto;
import com.tripan.app.mapper.TripPlaceMapper;
import com.tripan.app.service.TripPlaceService;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

/**
 * 장소 검색 / 추천 / 나만의 장소 REST API
 *
 * GET  /api/places/recommend  → 카테고리별 추천 (워크스페이스 추천패널)
 * GET  /api/places/search     → 키워드 검색     (장소 추가 모달)
 * GET  /api/places/my         → 나만의 장소 목록
 * POST /api/places/my         → 나만의 장소 등록
 * POST /api/places/sync       → 배치 수동 트리거 (개발/관리자용)
 */
@RestController
@RequestMapping("/api/places")
@RequiredArgsConstructor
public class TripPlaceApiController {

    private final TripPlaceService tripPlaceService;
    private final TripPlaceMapper tripPlaceMapper;

    // ── 카테고리별 추천 ──────────────────────────────────
    // GET /api/places/recommend?category=RESTAURANT&city=부산&limit=12
    @GetMapping("/recommend")
    public ResponseEntity<List<TripPlaceDto>> recommend(
            @RequestParam(value = "category", defaultValue = "all") String category,
            @RequestParam(value = "city",     defaultValue = "")    String city,
            @RequestParam(value = "limit",    defaultValue = "15")  int    limit,
            HttpSession session) {

        Long currentMemberId = getLoginMemberId(session);
        // "서울,부산" 콤마로 분리해서 List로 변환
        List<String> cityList = city.isBlank() ? List.of() : List.of(city.split(","));
        
        List<TripPlaceDto> results = tripPlaceMapper.selectRecommendPlaces(category, cityList, currentMemberId, limit);
        return ResponseEntity.ok(results);
    }
    
    // ── 키워드 검색 ──────────────────────────────────────
    // GET /api/places/search?keyword=흑돼지
    @GetMapping("/search")
    public ResponseEntity<List<TripPlaceDto>> search(
            @RequestParam("keyword") String keyword,
            HttpSession session) {

        Long memberId = getLoginMemberId(session);
        List<TripPlaceDto> result = tripPlaceService.searchPlaces(keyword, memberId);
        return ResponseEntity.ok(result);
    }

    // ── 나만의 장소 목록 ─────────────────────────────────
    // GET /api/places/my
    @GetMapping("/my")
    public ResponseEntity<?> myPlaces(HttpSession session) {
        Long memberId = getLoginMemberId(session);
        if (memberId == null)
            return ResponseEntity.status(401).body(Map.of("success", false, "message", "로그인이 필요합니다"));
        return ResponseEntity.ok(tripPlaceService.getMyPlaces(memberId));
    }

    // ── 나만의 장소 등록 ─────────────────────────────────
    // POST /api/places/my
    // Body: { placeName, address, latitude, longitude, category, imageUrl, phone }
    @PostMapping("/my")
    public ResponseEntity<?> registerMyPlace(
            @RequestBody TripPlaceDto dto,
            HttpSession session) {

        Long memberId = getLoginMemberId(session);
        if (memberId == null)
            return ResponseEntity.status(401).body(Map.of("success", false, "message", "로그인이 필요합니다"));
        if (dto.getPlaceName() == null || dto.getPlaceName().isBlank())
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", "장소명은 필수입니다"));

        TripPlaceDto saved = tripPlaceService.registerMyPlace(dto, memberId);
        return ResponseEntity.ok(Map.of("success", true, "place", saved));
    }

    // ── 배치 수동 트리거 (개발/관리자용) ────────────────────
    // POST /api/places/sync
    @PostMapping("/sync")
    public ResponseEntity<Map<String, Object>> syncBatch() {
        tripPlaceService.syncPlacesBatch();
        return ResponseEntity.ok(Map.of("success", true, "message", "동기화 완료"));
    }

    // ────────────────────────────────────────────────────
    private Long getLoginMemberId(HttpSession session) {
        Object user = session.getAttribute("loginUser");
        if (user == null) return null;
        try { return (Long) user.getClass().getMethod("getMemberId").invoke(user); }
        catch (Exception e) { return null; }
    }
}
