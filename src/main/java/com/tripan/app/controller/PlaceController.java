package com.tripan.app.controller;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.tripan.app.domain.dto.FestivalDto;
import com.tripan.app.domain.dto.PlaceDto;
import com.tripan.app.mapper.PlaceRecommendMapper;

import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/curation")
@RequiredArgsConstructor
public class PlaceController {

    private final PlaceRecommendMapper placeMapper;

    /** application.yml: tripan.api.kakao-map-api-key */
    @Value("${tripan.api.kakao-map-api-key}")
    private String kakaoMapsAppkey;

    /* ─────────────────────────────
       장소 상세
    ───────────────────────────── */
    @GetMapping("/detail")
    public String detail(@RequestParam("id") Long id, Model model) {

        PlaceDto place = placeMapper.selectPlaceDetailById(id);
        if (place == null) {
            return "redirect:/curation/place_list";
        }

        // ── 이미지 결정 ──
        List<String> images;
        if ("FESTIVAL".equalsIgnoreCase(place.getCategory())) {
            // 축제: festival_image 테이블 다중 이미지 (origin_img_url)
            images = placeMapper.selectFestivalImages(id);
            if (images == null || images.isEmpty()) {
                // fallback → place.image_url
                images = place.getImageUrl() != null && !place.getImageUrl().isBlank()
                        ? List.of(place.getImageUrl()) : List.of();
            }
        } else {
            // 그 외: place.image_url 단일 (없으면 빈 목록 → 캐러셀 숨김)
            images = place.getImageUrl() != null && !place.getImageUrl().isBlank()
                    ? List.of(place.getImageUrl()) : List.of();
        }
        place.setImages(images);

        model.addAttribute("place", place);
        model.addAttribute("kakaoAppKey", kakaoMapsAppkey);

        // ── 카테고리별 추가 데이터 ──
        if ("FESTIVAL".equalsIgnoreCase(place.getCategory())) {
            FestivalDto festival = placeMapper.selectFestivalDetailByPlaceId(id);
            model.addAttribute("festival", festival);
        }

        return "curation/detail";
    }

    /* ─────────────────────────────
       장소 목록
    ───────────────────────────── */
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

        // 큐레이션 목록: 이미지 있는 장소만
        List<PlaceDto> placeList = placeMapper.selectCurationPlaces(category, region, keyword, 12, 0);
        long totalCount          = placeMapper.countCurationPlaces(category, region, keyword);

        model.addAttribute("placeList",  placeList);
        model.addAttribute("totalCount", totalCount);

        return "curation/place_list";
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
