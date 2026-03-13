package com.tripan.app.service;

import com.tripan.app.domain.dto.PlaceDto;
import java.util.List;

public interface PlaceService {

    /**
     * 한국관광공사 API → DB 동기화 
     * 매일 새벽 3시 자동 실행 + 수동 트리거 가능
     * contentTypeId 대상: 12(관광지), 14(문화시설), 32(숙박), 38(쇼핑), 39(음식점), 28(레포츠)
     */
    void syncPlacesBatch();

    /**
     * 카테고리별 추천 장소 
     * @param category    TOUR / STAY / RESTAURANT / CULTURE / LEISURE / SHOPPING / all
     * @param cityKeyword 여행지 도시명 (예: "부산", "제주")
     * @param limit       반환 개수
     */
    List<PlaceDto> getRecommendPlaces(String category, String cityKeyword, int limit);
}