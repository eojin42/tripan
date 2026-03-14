package com.tripan.app.controller;

import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.tripan.app.service.TourApiSyncService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/admin/sync") // 관리자나 테스트용 경로
@RequiredArgsConstructor
// 장소(식당/관광지/레포츠/쇼핑 등) 상세정보 동기화 컨트롤
public class TourApiSyncController {

    private final TourApiSyncService syncService;

    // 🟢 이 주소로 접속하면 강제로 50개씩 동기화가 실행됩니다!
    @GetMapping("/places")
    public ResponseEntity<Map<String, String>> triggerSync() {
        String resultMessage = syncService.forceSyncPlaceDetails();
        return ResponseEntity.ok(Map.of("result", resultMessage));
    }
}