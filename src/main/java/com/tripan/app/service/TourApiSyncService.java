package com.tripan.app.service;

import java.util.Map;

public interface TourApiSyncService {

    /**
     * 설명이 없는(NULL) 장소를 찾아 TourAPI detailCommon2로 동기화합니다.
     * → place 테이블의 description, phone_number 업데이트
     */
    String forceSyncPlaceDetails();

    /**
     * 식당(contentTypeId=39) 상세 정보를 TourAPI detailIntro2로 실시간 조회합니다.
     * → 워크스페이스 모달 등 즉시 조회용 (DB 저장 X)
     */
    Map<String, Object> getRestaurantDetail(String contentId);

    /**
     * 식당(contentTypeId=39) 상세를 배치로 DB에 저장합니다.
     * → restaurant / restaurant_facility / restaurant_menu 테이블 MERGE
     */
    String forceSyncRestaurantDetails();

    /**
     * 이미지가 없는 장소의 firstimage를 TourAPI detailCommon2로 채웁니다.
     * → place 테이블의 image_url 업데이트
     */
    String forceSyncPlaceImages();

    /**
     * 관광지/문화시설/레포츠 상세를 배치로 DB에 저장합니다.
     * → attraction 테이블 MERGE
     * contentTypeId: TOUR=12, CULTURE=14, LEISURE=28
     */
    String forceSyncAttractionDetails();
}
