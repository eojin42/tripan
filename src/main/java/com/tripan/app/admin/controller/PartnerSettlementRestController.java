package com.tripan.app.admin.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.tripan.app.admin.domain.dto.SettlementFilterDto;
import com.tripan.app.admin.domain.dto.SettlementManageDto;
import com.tripan.app.admin.domain.dto.SettlementOrderDto;
import com.tripan.app.admin.service.PartnerSettlementService;
import com.tripan.app.security.CustomUserDetails;

import lombok.RequiredArgsConstructor;

@RestController
@RequiredArgsConstructor
@RequestMapping("/admin/settlement")
public class PartnerSettlementRestController {
	private final PartnerSettlementService settlementService;
	 
    // ─────────────────────────────────────────────
    //  메인 목록 데이터 (AJAX)
    //  GET /admin/settlement/list
    // ─────────────────────────────────────────────
    @GetMapping("/list")
    public Map<String, Object> list(SettlementFilterDto filter) {
        List<SettlementManageDto> list  = settlementService.getSummaryList(filter);
        int                       total = settlementService.getSummaryCount(filter);
 
        Map<String, Object> result = new HashMap<>();
        result.put("list",  list);
        result.put("total", total);
        result.put("page",  filter.getPage());
        result.put("size",  filter.getSize());
        return result;
    }
 
    // ─────────────────────────────────────────────
    //  숙소별 예약 건 목록 (상세 페이지 아코디언)
    //  GET /admin/settlement/orders?placeId=&month=
    // ─────────────────────────────────────────────
    @GetMapping("/orders")
    public List<SettlementManageDto> orders(
            @RequestParam Long   placeId,
            @RequestParam String month
    ) {
        SettlementFilterDto filter = new SettlementFilterDto();
        filter.setPlaceId(placeId);
        filter.setSettlementMonth(month);
        return settlementService.getDetailList(filter);
    }
 
    // ─────────────────────────────────────────────
    //  정산 승인 - 숙소 단위
    //  POST /admin/settlement/approve/place
    // ─────────────────────────────────────────────
    @PostMapping("/approve/place")
    public Map<String, Object> approvePlace(
            @RequestParam Long   placeId,
            @RequestParam String month,
            @AuthenticationPrincipal CustomUserDetails user
    ) {
        Map<String, Object> res = new HashMap<>();
        try {
            settlementService.approvePlace(placeId, month, user.getMember().getMemberId());
            res.put("success", true);
        } catch (Exception e) {
            res.put("success", false);
            res.put("message", e.getMessage());
        }
        return res;
    }
 
    // ─────────────────────────────────────────────
    //  정산 승인 - 파트너 전체 일괄
    //  POST /admin/settlement/approve/partner
    // ─────────────────────────────────────────────
    @PostMapping("/approve/partner")
    public Map<String, Object> approvePartner(
            @RequestParam Long   memberId,
            @RequestParam String month,
            @AuthenticationPrincipal CustomUserDetails user
    ) {
        Map<String, Object> res = new HashMap<>();
        try {
            settlementService.approveAllByPartner(memberId, month, user.getMember().getMemberId());
            res.put("success", true);
        } catch (Exception e) {
            res.put("success", false);
            res.put("message", e.getMessage());
        }
        return res;
    }
 
    // ─────────────────────────────────────────────
    //  CSV 다운로드용 데이터 - 파트너 단위
    //  GET /admin/settlement/csv/partner?memberId=&month=
    // ─────────────────────────────────────────────
    @GetMapping("/csv/partner")
    public List<SettlementOrderDto> csvPartner(
            @RequestParam Long   memberId,
            @RequestParam String month
    ) {
        SettlementFilterDto filter = new SettlementFilterDto();
        filter.setMemberId(memberId);
        filter.setSettlementMonth(month);
        return settlementService.getExcelRowsByPartner(filter);
    }
 
    // ─────────────────────────────────────────────
    //  CSV 다운로드용 데이터 - 숙소 단위
    //  GET /admin/settlement/csv/place?placeId=&month=
    // ─────────────────────────────────────────────
    @GetMapping("/csv/place")
    public List<SettlementOrderDto> csvPlace(
            @RequestParam Long   placeId,
            @RequestParam String month
    ) {
        SettlementFilterDto filter = new SettlementFilterDto();
        filter.setPlaceId(placeId);
        filter.setSettlementMonth(month);
        return settlementService.getExcelRowsByPlace(filter);
    }

 // PartnerSettlementRestController에 임시 추가
    @GetMapping("/batch/test")
    public String batchTest() {
        settlementService.aggregateSettlement();
        return "완료";
    }
}
