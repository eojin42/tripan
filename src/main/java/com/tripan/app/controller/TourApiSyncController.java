package com.tripan.app.controller;

import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.tripan.app.service.TourApiSyncService;

import lombok.RequiredArgsConstructor;

/**
 * TourAPI → DB 배치 동기화 트리거 (관리자/테스트용)
 *
 * 사용 흐름:
 *  1. GET /api/admin/sync/places       → place 테이블 description, phone_number 업데이트
 *  2. GET /api/admin/sync/restaurants  → restaurant 테이블 영업시간/휴무일 등 업데이트
 *  3. GET /api/admin/sync/attractions  → attraction 테이블 휴무일/이용시간 업데이트  ← NEW
 *
 * 동작 방식:
 *  - TourAPI(한국관광공사 detailIntro2) 를 호출하여 결과를 각 테이블에 MERGE(UPSERT)
 *  - 이미 데이터가 있는 장소는 건너뜀(attraction 테이블에 없는 것만 조회 대상)
 *  - 저장 후에는 /curation/detail 조회 시 DB JOIN으로 빠르게 사용
 */
@RestController
@RequestMapping("/api/admin/sync")
@RequiredArgsConstructor
public class TourApiSyncController {

    private final TourApiSyncService syncService;

    /** place 테이블 description / phone_number 동기화 */
    @GetMapping("/places")
    public ResponseEntity<Map<String, String>> triggerSync() {
        String result = syncService.forceSyncPlaceDetails();
        return ResponseEntity.ok(Map.of("result", result));
    }

    /**
     * 식당 상세 동기화 (contentTypeId=39)
     * → restaurant / restaurant_facility / restaurant_menu 테이블 MERGE
     */
    @GetMapping("/restaurants")
    public ResponseEntity<String> syncRestaurants() {
        return ResponseEntity.ok(syncService.forceSyncRestaurantDetails());
    }

    /**
     * 이미지 없는 장소 image_url 채우기
     * 호출: GET http://localhost:9090/api/admin/sync/images
     * (할당량 제한 있으므로 여러 번 호출해서 점진적으로 채우기)
     */
    @GetMapping("/images")
    public ResponseEntity<String> syncImages() {
        return ResponseEntity.ok(syncService.forceSyncPlaceImages());
    }

    //호출: GET http://localhost:9090/api/admin/sync/attractions
    @GetMapping("/attractions")
    public ResponseEntity<String> syncAttractions() {
        return ResponseEntity.ok(syncService.forceSyncAttractionDetails());
    }
}
