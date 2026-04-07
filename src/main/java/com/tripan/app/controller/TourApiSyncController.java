package com.tripan.app.controller;

import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.tripan.app.service.TourApiSyncService;

import lombok.RequiredArgsConstructor;


@RestController
@RequestMapping("/api/admin/sync")
@RequiredArgsConstructor
public class TourApiSyncController {

    private final TourApiSyncService syncService;

    /** place 테이블 description / phone_number 동기화 */
    @GetMapping("/places")
    public ResponseEntity<Map<String, String>> syncPlaces() {
        String result = syncService.forceSyncPlaceDetails();
        return ResponseEntity.ok(Map.of("result", result));
    }

    /** 식당 상세 동기화 → restaurant / restaurant_facility / menu */
    @GetMapping("/restaurants")
    public ResponseEntity<String> syncRestaurants() {
        return ResponseEntity.ok(syncService.forceSyncRestaurantDetails());
    }

    /** 관광지/문화/레포츠 상세 동기화 → attraction */
    @GetMapping("/attractions")
    public ResponseEntity<String> syncAttractions() {
        return ResponseEntity.ok(syncService.forceSyncAttractionDetails());
    }

    /**
     * 통합 배치 — places + images + restaurants + attractions 한번에
     * 호출: GET http://localhost:9090/api/admin/sync/all
     */
    @GetMapping("/all")
    public ResponseEntity<String> syncAll() {
        return ResponseEntity.ok(syncService.forceSyncAll());
    }
}