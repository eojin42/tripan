package com.tripan.app.admin.controller;

import java.time.LocalDate;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.tripan.app.admin.domain.dto.PlatformSettlementDto;
import com.tripan.app.admin.service.PlatformSettlementService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Controller
@RequiredArgsConstructor
@Slf4j
@RequestMapping("/admin/settlement/platform")
public class PlatformSettlementController {
	private final PlatformSettlementService settlementService;
	
	@GetMapping("/main")
	public String main() {
		return "admin/platformSettlement/main";
	}
	
	/**
     * 플랫폼 정산 데이터 조회 (KPI + 월별 목록)
     * GET /admin/settlement/platform/data?year=2026&month=03
     *
     * month 를 생략하면 연간 전체 반환
     */
    @GetMapping("/data")
    @ResponseBody
    public ResponseEntity<?> getData(
            @RequestParam(value = "year",  required = false) Integer year,
            @RequestParam(value = "month", required = false) String  month) {
 
        // 연도 기본값: 현재 연도
        if (year == null) {
            year = LocalDate.now().getYear();
        }
        // 빈 문자열을 null 로 통일
        if (month != null && month.isBlank()) {
            month = null;
        }
 
        try {
            PlatformSettlementDto.PageResponse data =
                    settlementService.getPageData(year, month);
            return ResponseEntity.ok(data);
        } catch (Exception e) {
            log.error("[PlatformSettlement] 데이터 조회 실패", e);
            return ResponseEntity.internalServerError()
                    .body(Map.of("success", false, "message", "데이터 조회에 실패했습니다."));
        }
    }
}
