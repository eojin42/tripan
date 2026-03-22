package com.tripan.app.admin.controller;

import com.tripan.app.admin.domain.dto.PointManageDto;
import com.tripan.app.admin.service.PointManageService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/admin/api/point")
@RequiredArgsConstructor
public class PointManageRestController {

    private final PointManageService pointManageService;

    /* ── 회원별 포인트 요약 목록
         GET /admin/api/point/members?keyword=&startDate=&endDate= ── */
    @GetMapping("/members")
    public ResponseEntity<List<PointManageDto>> getMemberPointList(
            @RequestParam(name = "keyword",   required = false) String keyword,
            @RequestParam(name = "startDate", required = false) String startDate,
            @RequestParam(name = "endDate",   required = false) String endDate) {

        PointManageDto.SearchRequest req = new PointManageDto.SearchRequest();
        req.setKeyword(keyword);
        req.setStartDate(startDate);
        req.setEndDate(endDate);

        return ResponseEntity.ok(pointManageService.getMemberPointList(req));
    }

    /* ── 개인 포인트 내역
         GET /admin/api/point/members/{memberId}/history?startDate=&endDate= ── */
    @GetMapping("/members/{memberId}/history")
    public ResponseEntity<List<PointManageDto.HistoryDto>> getPointHistory(
            @PathVariable("memberId") Long memberId,
            @RequestParam(name = "startDate", required = false) String startDate,
            @RequestParam(name = "endDate",   required = false) String endDate) {

        return ResponseEntity.ok(
                pointManageService.getPointHistory(memberId, startDate, endDate));
    }

    /* ── 포인트 지급/차감 (개인 or 일괄)
         POST /admin/api/point/adjust ── */
    @PostMapping("/adjust")
    public ResponseEntity<Void> adjustPoints(
            @RequestBody PointManageDto.AdjustRequest request) {
        pointManageService.adjustPoints(request);
        return ResponseEntity.ok().build();
    }

    /* ── 예외 처리 ── */
    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<Map<String, String>> handleIllegalArg(IllegalArgumentException e) {
        log.warn("[PointManage] 잘못된 요청: {}", e.getMessage());
        return ResponseEntity.badRequest().body(Map.of("message", e.getMessage()));
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<Map<String, String>> handleException(Exception e) {
        log.error("[PointManage] 서버 오류", e);
        return ResponseEntity.internalServerError().body(Map.of("message", "서버 오류가 발생했습니다."));
    }
}