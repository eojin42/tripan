package com.tripan.app.controller;

import com.tripan.app.mapper.TripPlaceMapper;
import com.tripan.app.security.CustomUserDetails;
import com.tripan.app.trip.domain.entity.TripPlace;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 장소 검색 · 추천 API
 * 
 * - GET /api/place/search?keyword=xxx         → DB trip_place 키워드 검색
 * - GET /api/place/recommend?category=xxx     → DB 추천 장소 목록
 */
@RestController
@RequestMapping("/api/place")
@RequiredArgsConstructor
public class PlaceApiController {

    private final TripPlaceMapper tripPlaceMapper;

    /**
     * 장소 검색 (카카오 API 대체 — DB 기반)
     * workspace.schedule.js의 searchPlace()에서 호출
     */
    @GetMapping("/search")
    public List<TripPlace> searchPlaces(
            @RequestParam String keyword,
            @RequestParam(required = false) String category,
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        Long memberId = userDetails != null ? userDetails.getMember().getMemberId() : null;
        return tripPlaceMapper.searchPlaces(memberId, keyword, category);
    }

    /**
     * 추천 장소 (태그/카테고리 기반)
     * workspace.recommend.js에서 호출
     */
    @GetMapping("/recommend")
    public List<Map<String, Object>> recommendPlaces(
            @RequestParam(required = false) String category,
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        Long memberId = userDetails != null ? userDetails.getMember().getMemberId() : null;
        // tagNames는 향후 추천 알고리즘 고도화 시 활용
        return tripPlaceMapper.selectRecommendedPlaces(memberId, category, null);
    }
}
