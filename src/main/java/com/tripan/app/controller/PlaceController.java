package com.tripan.app.controller;

import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.tripan.app.domain.dto.PlaceDto;
import com.tripan.app.mapper.PlaceRecommendMapper;

import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/curation")
@RequiredArgsConstructor
public class PlaceController {

    private final PlaceRecommendMapper placeMapper;
    
    /* ─────────────────────────────
       장소 상세 (placeId 변수명 및 경로 일치)
    ───────────────────────────── */
    @GetMapping("/detail")
    public String detail(@RequestParam("id") Long id, Model model) {
        // 매퍼 인터페이스의 @Param("placeId")와 일치시킴
        PlaceDto place = placeMapper.selectPlaceDetailById(id);
        
        if (place == null) {
            return "redirect:/curation/place_list";
        }
        
        // 상세페이지 전용 이미지 목록 조회
        place.setImages(placeMapper.selectPlaceImages(id));
        
        model.addAttribute("place", place);
        return "curation/detail";
    }

    /* ─────────────────────────────
       장소 목록 (필터/검색/초기 데이터)
    ───────────────────────────── */
    @GetMapping("/place_list")
    public String place_list(
            @RequestParam(value = "keyword", required = false, defaultValue = "") String keyword,
            @RequestParam(value = "category", required = false, defaultValue = "전체") String category,
            @RequestParam(value = "region", required = false, defaultValue = "전체") String region,
            Model model) {

        // 1. 사이드바용 시/도 목록
        model.addAttribute("regionList", placeMapper.selectDistinctRegions());

        // 2. 카테고리 탭 목록
        model.addAttribute("categoryList", buildCategoryList());

        // 3. 현재 검색 상태 유지용
        model.addAttribute("keyword",  keyword);
        model.addAttribute("category", category);
        model.addAttribute("region",   region);

        // 4. 초기 데이터 조회 (keyword 포함, region은 String 그대로 전달)
        // 매퍼 인터페이스 수정본: selectRecommendPlaces(category, region, keyword, limit, offset)
        List<PlaceDto> placeList = placeMapper.selectRecommendPlaces(category, region, keyword, 12, 0);
        long totalCount = placeMapper.countRecommendPlaces(category, region, keyword);

        model.addAttribute("placeList",  placeList);
        model.addAttribute("totalCount", totalCount);

        return "curation/place_list";
    }

    private List<Map<String, String>> buildCategoryList() {
        return List.of(
            Map.of("label", "전체",     "value", "전체"),
            Map.of("label", "관광지",   "value", "TOUR"),       // DB값이 TOUR라면 value를 맞춰야 함
            Map.of("label", "음식점",   "value", "RESTAURANT"), // DB값이 RESTAURANT라면 value를 맞춰야 함
            Map.of("label", "숙박",     "value", "ACCOMMODATION"),
            Map.of("label", "문화시설", "value", "CULTURE"),
            Map.of("label", "레포츠",   "value", "LEISURE"),
            Map.of("label", "쇼핑",     "value", "SHOPPING"),
            Map.of("label", "축제",     "value", "FESTIVAL")
        );
    }
}