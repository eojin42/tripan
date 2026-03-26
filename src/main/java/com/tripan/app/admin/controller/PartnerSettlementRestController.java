package com.tripan.app.admin.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.tripan.app.admin.domain.dto.SettlementFilterDto;
import com.tripan.app.admin.domain.dto.SettlementManageDto;
import com.tripan.app.admin.domain.dto.SettlementOrderDto;
import com.tripan.app.admin.service.PartnerSettlementService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/admin/settlement/partner")
@RequiredArgsConstructor
public class PartnerSettlementRestController {

    private final PartnerSettlementService settlementService;

    // ─────────────────────────────────────────────
    //  목록 조회
    //  GET /admin/settlement/partner/list
    // ─────────────────────────────────────────────
    @GetMapping(value = "/list", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<?> list(
            @RequestParam(value = "settlementMonth", required = false) String settlementMonth,
            @RequestParam(value = "status",          required = false) String status,
            @RequestParam(value = "region",          required = false) String region,
            @RequestParam(value = "keyword",         required = false) String keyword,
            @RequestParam(value = "page",  defaultValue = "1")  int page,
            @RequestParam(value = "size",  defaultValue = "20") int size
    ) {
        SettlementFilterDto filter = new SettlementFilterDto();
        filter.setSettlementMonth(settlementMonth);
        filter.setStatus(status);
        filter.setRegion(region);
        filter.setKeyword(keyword);
        filter.setPage(page);
        filter.setSize(size);

        List<SettlementManageDto> list  = settlementService.getSummaryList(filter);
        int                       total = settlementService.getSummaryCount(filter);

        return ResponseEntity.ok(java.util.Map.of("list", list, "total", total));
    }

    // ─────────────────────────────────────────────
    //  개별 파트너(숙소) 1개 승인
    //  POST /admin/settlement/partner/approve/place
    //  파라미터: partnerId (partner_id), settlementMonth
    // ─────────────────────────────────────────────
    @PostMapping("/approve/place")
    public ResponseEntity<String> approvePlace(
            @RequestParam("partnerId")       Long   partnerId,
            @RequestParam("settlementMonth") String settlementMonth,
            @RequestParam(value = "adminId", defaultValue = "0") Long adminId
    ) {
        try {
            settlementService.approvePlace(partnerId, settlementMonth, adminId);
            return ResponseEntity.ok("ok");
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    // ─────────────────────────────────────────────
    //  멤버 소속 파트너 전체 일괄 승인
    //  POST /admin/settlement/partner/approve/all
    //  파라미터: memberId (member_id), settlementMonth
    //  → 소속 파트너 전체 순회하며 각각 upsertSettlement
    //  → partial 상태에서 미승인 파트너만 추가 승인도 가능
    // ─────────────────────────────────────────────
    @PostMapping("/approve/all")
    public ResponseEntity<String> approveAll(
            @RequestParam("memberId")        Long   memberId,
            @RequestParam("settlementMonth") String settlementMonth,
            @RequestParam(value = "adminId", defaultValue = "0") Long adminId
    ) {
        try {
            settlementService.approveAllByPartner(memberId, settlementMonth, adminId);
            return ResponseEntity.ok("ok");
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    // ─────────────────────────────────────────────
    //  KPI 조회 (main.jsp 상단 카드 4개)
    //  GET /admin/settlement/partner/kpi
    //  - done    → doneAmt / doneCount
    //  - partial → pendingAmt / pendingCount (미완료이므로 대기로 분류)
    //  - wait    → pendingAmt / pendingCount
    // ─────────────────────────────────────────────
    @GetMapping(value = "/kpi", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<?> kpi(
            @RequestParam(value = "settlementMonth", required = false) String settlementMonth
    ) {
        SettlementFilterDto filter = new SettlementFilterDto();
        filter.setSettlementMonth(settlementMonth);
        filter.setPage(1);
        filter.setSize(9999);

        List<SettlementManageDto> list = settlementService.getSummaryList(filter);

        java.math.BigDecimal totalGmv        = java.math.BigDecimal.ZERO;
        java.math.BigDecimal totalCommission = java.math.BigDecimal.ZERO;
        java.math.BigDecimal pendingAmt      = java.math.BigDecimal.ZERO;
        java.math.BigDecimal doneAmt         = java.math.BigDecimal.ZERO;
        int pendingCount = 0, doneCount = 0;

        for (SettlementManageDto d : list) {
            if (d.getTotalGmv()        != null) totalGmv        = totalGmv.add(d.getTotalGmv());
            if (d.getTotalCommission() != null) totalCommission = totalCommission.add(d.getTotalCommission());

            String status = d.getSettlementStatus();
            if ("done".equals(status)) {
                // 전체 승인 완료
                if (d.getTotalNetPayout() != null) doneAmt = doneAmt.add(d.getTotalNetPayout());
                doneCount++;
            } else {
                // wait(대기) 또는 partial(부분승인) 모두 정산 대기 금액으로 집계
                if (d.getTotalNetPayout() != null) pendingAmt = pendingAmt.add(d.getTotalNetPayout());
                pendingCount++;
            }
        }

        return ResponseEntity.ok(java.util.Map.of(
            "totalGmv",        totalGmv,
            "totalCommission", totalCommission,
            "pendingAmt",      pendingAmt,
            "pendingCount",    pendingCount,
            "doneAmt",         doneAmt,
            "doneCount",       doneCount
        ));
    }

    // ─────────────────────────────────────────────
    //  CSV — 멤버 소속 전체 파트너 예약 건별
    //  GET /admin/settlement/partner/csv/partner
    // ─────────────────────────────────────────────
    @GetMapping("/csv/partner")
    public ResponseEntity<List<SettlementOrderDto>> csvByPartner(
            @RequestParam("memberId") Long   memberId,
            @RequestParam("month")    String month
    ) {
        SettlementFilterDto filter = new SettlementFilterDto();
        filter.setMemberId(memberId);
        filter.setSettlementMonth(month);
        return ResponseEntity.ok(settlementService.getExcelRowsByPartner(filter));
    }

    // ─────────────────────────────────────────────
    //  CSV — 숙소(place) 단위 예약 건별
    //  GET /admin/settlement/partner/csv/place
    // ─────────────────────────────────────────────
    @GetMapping("/csv/place")
    public ResponseEntity<List<SettlementOrderDto>> csvByPlace(
            @RequestParam("placeId") Long   placeId,
            @RequestParam("month")   String month
    ) {
        SettlementFilterDto filter = new SettlementFilterDto();
        filter.setPlaceId(placeId);
        filter.setSettlementMonth(month);
        return ResponseEntity.ok(settlementService.getExcelRowsByPlace(filter));
    }

    // ─────────────────────────────────────────────
    //  배치 테스트용 (운영 배포 전 제거)
    //  GET /admin/settlement/partner/batch/test
    // ─────────────────────────────────────────────
    @GetMapping("/batch/test")
    public ResponseEntity<String> batchTest() {
        settlementService.aggregateSettlement();
        return ResponseEntity.ok("배치 실행 완료");
    }
}