package com.tripan.app.service;

public interface TourApiSyncService {
    /**
     * 설명이 없는(NULL) 장소를 50개 찾아 한국관광공사 API와 동기화합니다.
     * @return 동기화 결과 메시지
     */
    String forceSyncPlaceDetails();

    /**
     * 식당(contentTypeId=39) 상세 정보를 TourAPI detailIntro2 로 실시간 조회합니다.
     * @param contentId KTO contentid (= place.place_id)
     * @return 영업시간, 휴무일, 주차, 예약, 카드, 키즈존, 포장, 문의처
     */
    java.util.Map<String, Object> getRestaurantDetail(String contentId);
    
    String forceSyncRestaurantDetails();
}