package com.tripan.app.service;

public interface TourApiSyncService {
    /**
     * 설명이 없는(NULL) 장소를 50개 찾아 한국관광공사 API와 동기화합니다.
     * @return 동기화 결과 메시지
     */
    String forceSyncPlaceDetails();
}