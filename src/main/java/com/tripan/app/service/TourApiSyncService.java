package com.tripan.app.service;

import java.util.Map;

public interface TourApiSyncService {

    /** place 테이블의 description, phone_number 배치 업데이트 */
    String forceSyncPlaceDetails();

    /** place 테이블의 image_url 배치 업데이트 */
    String forceSyncPlaceImages();

    /** 식당 실시간 단건 조회 (DB 저장 X, 워크스페이스 모달용) */
    Map<String, Object> getRestaurantDetail(String contentId);

    /** 식당 배치 동기화 → restaurant / restaurant_facility / menu */
    String forceSyncRestaurantDetails();

    /** 관광지/문화/레포츠 배치 동기화 → attraction */
    String forceSyncAttractionDetails();

    /**
     * [온디맨드] 디테일 진입 시 해당 장소 DB에 없으면 즉시 API 호출 → 저장
     * PlaceController.detail()에서 호출
     */
    void syncOnDemand(Long placeId, String category);

    /**
     * [통합 배치] place + 이미지 + 식당 + 관광지 한번에 전부 동기화
     * GET /api/admin/sync/all
     */
    String forceSyncAll();
}