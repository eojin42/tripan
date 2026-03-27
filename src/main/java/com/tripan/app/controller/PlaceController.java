package com.tripan.app.controller;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.tripan.app.domain.dto.FestivalDto;
import com.tripan.app.domain.dto.PlaceDto;
import com.tripan.app.mapper.PlaceMapper;
import com.tripan.app.mapper.PlaceRecommendMapper;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

import com.tripan.app.service.TourApiSyncService;

@Controller
@RequestMapping("/curation")
@RequiredArgsConstructor
public class PlaceController {

    private final PlaceRecommendMapper placeMapper;
    private final PlaceMapper          placeWriteMapper; // 조회수/좋아요 쓰기
    private final TourApiSyncService   tourApiSyncService; // 온디맨드 sync

    @Value("${tripan.api.kakao-map-api-key}")
    private String kakaoMapsAppkey;

    /* ────────────────────────────────────
       장소 상세
    ──────────────────────────────────── */
    @GetMapping("/detail")
    public String detail(@RequestParam("id") Long id,
                         HttpSession session,
                         Model model) {

        PlaceDto place = placeMapper.selectPlaceDetailById(id);
        if (place == null) return "redirect:/curation/place_list";

        // ★ 온디맨드 sync (@Async) — 백그라운드에서 채움, 사용자 대기 없음
        // 다음 방문부터 데이터 표시됨
        tourApiSyncService.syncOnDemand(id, place.getCategory());

        // 조회수 +1
        placeWriteMapper.incrementViewCount(id);

        // 이미지 결정
        List<String> images;
        if ("FESTIVAL".equalsIgnoreCase(place.getCategory())) {
            images = placeMapper.selectFestivalImages(id);
            if (images == null || images.isEmpty()) {
                images = place.getImageUrl() != null && !place.getImageUrl().isBlank()
                        ? List.of(place.getImageUrl()) : List.of();
            }
        } else {
            images = place.getImageUrl() != null && !place.getImageUrl().isBlank()
                    ? List.of(place.getImageUrl()) : List.of();
        }
        place.setImages(images);
        // 조회수 +1 반영 (화면에는 업데이트된 값 보여주기)
        place.setViewCount(place.getViewCount() != null ? place.getViewCount() + 1 : 1L);

        // 좋아요 상태 (place.likeCount는 selectPlaceDetailById에서 이미 계산됨)
        Long memberId = getLoginMemberId(session);
        boolean liked = false;
        if (memberId != null) {
            liked = placeWriteMapper.countLike(memberId, id) > 0;
        }
        long likeCount = place.getLikeCount() != null ? place.getLikeCount() : 0L;

        model.addAttribute("place",      place);
        model.addAttribute("kakaoAppKey", kakaoMapsAppkey);
        model.addAttribute("liked",      liked);
        model.addAttribute("likeCount",  likeCount);
        model.addAttribute("isLoggedIn", memberId != null);

        if ("FESTIVAL".equalsIgnoreCase(place.getCategory())) {
            FestivalDto festival = placeMapper.selectFestivalDetailByPlaceId(id);
            model.addAttribute("festival", festival);
        }

        return "curation/detail";
    }

    /* ────────────────────────────────────
       좋아요 토글  POST /curation/like/{placeId}
    ──────────────────────────────────── */
    @PostMapping("/like/{placeId}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> toggleLike(
            @PathVariable("placeId") Long placeId,
            HttpSession session) {

        Long memberId = getLoginMemberId(session);
        if (memberId == null)
            return ResponseEntity.status(401)
                    .body(Map.of("success", false, "message", "로그인이 필요합니다"));

        boolean alreadyLiked = placeWriteMapper.countLike(memberId, placeId) > 0;
        if (alreadyLiked) placeWriteMapper.deleteLike(memberId, placeId);
        else              placeWriteMapper.insertLike(memberId, placeId);

        long likeCount = placeWriteMapper.countLikeTotal(placeId);
        return ResponseEntity.ok(Map.of(
                "success",   true,
                "liked",     !alreadyLiked,
                "likeCount", likeCount));
    }

    /* ────────────────────────────────────
       장소 목록
    ──────────────────────────────────── */
    @GetMapping("/place_list")
    public String place_list(
            @RequestParam(value = "keyword",  required = false, defaultValue = "") String keyword,
            @RequestParam(value = "category", required = false, defaultValue = "전체") String category,
            @RequestParam(value = "region",   required = false, defaultValue = "전체") String region,
            Model model) {

        model.addAttribute("regionList",   placeMapper.selectDistinctRegions());
        model.addAttribute("categoryList", buildCategoryList());
        model.addAttribute("keyword",      keyword);
        model.addAttribute("category",     category);
        model.addAttribute("region",       region);

        List<PlaceDto> placeList = placeMapper.selectCurationPlaces(category, region, keyword, 12, 0, "recent");
        long totalCount          = placeMapper.countCurationPlaces(category, region, keyword);

        model.addAttribute("placeList",  placeList);
        model.addAttribute("totalCount", totalCount);

        return "curation/place_list";
    }

    private Long getLoginMemberId(HttpSession session) {
        Object user = session.getAttribute("loginUser");
        if (user == null) return null;
        try { return (Long) user.getClass().getMethod("getMemberId").invoke(user); }
        catch (Exception e) { return null; }
    }

    private List<Map<String, String>> buildCategoryList() {
        return List.of(
            Map.of("label", "전체",     "value", "전체"),
            Map.of("label", "관광지",   "value", "TOUR"),
            Map.of("label", "음식점",   "value", "RESTAURANT"),
            Map.of("label", "숙박",     "value", "ACCOMMODATION"),
            Map.of("label", "문화시설", "value", "CULTURE"),
            Map.of("label", "레포츠",   "value", "LEISURE"),
            Map.of("label", "쇼핑",     "value", "SHOPPING"),
            Map.of("label", "축제",     "value", "FESTIVAL")
        );
    }
}