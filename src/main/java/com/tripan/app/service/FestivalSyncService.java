package com.tripan.app.service;

public interface FestivalSyncService {
    
    /**
     * 공공데이터포털 축제 API를 호출하여 DB에 동기화하는 배치 메서드
     */
    void syncFestivalsBatch();
    
}