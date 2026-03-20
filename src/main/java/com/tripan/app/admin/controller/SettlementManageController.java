package com.tripan.app.admin.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.tripan.app.admin.domain.dto.SettlementFilterDto;
import com.tripan.app.admin.domain.dto.SettlementManageDto;
import com.tripan.app.admin.domain.dto.SettlementOrderDto;
import com.tripan.app.admin.service.SettlementManageService;
import com.tripan.app.security.CustomUserDetails;

import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/admin/settlement")
@RequiredArgsConstructor
public class SettlementManageController {

	 private final SettlementManageService settlementService;

	    // ─────────────────────────────────────────────
	    //  메인 목록 페이지
	    //  GET /admin/settlement/main
	    // ─────────────────────────────────────────────
	    @GetMapping("/main")
	    public String main() {
	        return "admin/settlement/main";
	    }

	    // ─────────────────────────────────────────────
	    //  메인 목록 데이터 (AJAX)
	    //  GET /admin/settlement/list
	    // ─────────────────────────────────────────────
	    @GetMapping("/list")
	    @ResponseBody
	    public Map<String, Object> list(SettlementFilterDto filter) {
	        List<SettlementManageDto> list  = settlementService.getSummaryList(filter);
	        int                        total = settlementService.getSummaryCount(filter);

	        Map<String, Object> result = new HashMap<>();
	        result.put("list",  list);
	        result.put("total", total);
	        result.put("page",  filter.getPage());
	        result.put("size",  filter.getSize());
	        return result;
	    }

	    // ─────────────────────────────────────────────
	    //  상세 페이지 (별도 페이지)
	    //  GET /admin/settlement/detail/{memberId}?month=YYYY-MM
	    // ─────────────────────────────────────────────
	    @GetMapping("/detail/{memberId}")
	    public String detail(
	            @PathVariable("memberId") Long memberId,
	            @RequestParam(value = "month", required = false) String month,
	            Model model
	    ) {
	        SettlementFilterDto filter = new SettlementFilterDto();
	        filter.setMemberId(memberId);
	        filter.setSettlementMonth(month);

	        List<SettlementManageDto> details = settlementService.getDetailList(filter);

	        // 파트너 전체 합산 (detail.jsp KPI 영역용)
	        java.math.BigDecimal totalGmv            = java.math.BigDecimal.ZERO;
	        java.math.BigDecimal totalCommission     = java.math.BigDecimal.ZERO;
	        java.math.BigDecimal totalCouponPlatform = java.math.BigDecimal.ZERO;
	        java.math.BigDecimal totalCouponPartner  = java.math.BigDecimal.ZERO;
	        java.math.BigDecimal totalNetPayout      = java.math.BigDecimal.ZERO;
	        int approvedPlaceCount = 0;

	        for (SettlementManageDto d : details) {
	            if (d.getTotalGmv()            != null) totalGmv            = totalGmv.add(d.getTotalGmv());
	            if (d.getTotalCommission()     != null) totalCommission     = totalCommission.add(d.getTotalCommission());
	            if (d.getTotalCouponPlatform() != null) totalCouponPlatform = totalCouponPlatform.add(d.getTotalCouponPlatform());
	            if (d.getTotalCouponPartner()  != null) totalCouponPartner  = totalCouponPartner.add(d.getTotalCouponPartner());
	            if (d.getTotalNetPayout()      != null) totalNetPayout      = totalNetPayout.add(d.getTotalNetPayout());
	            if ("APPROVED".equals(d.getSettlementStatus())) approvedPlaceCount++;
	        }

	        model.addAttribute("memberId",            memberId);
	        model.addAttribute("settlementMonth",      month);
	        model.addAttribute("details",              details);
	        model.addAttribute("totalGmv",             totalGmv);
	        model.addAttribute("totalCommission",      totalCommission);
	        model.addAttribute("totalCouponPlatform",  totalCouponPlatform);
	        model.addAttribute("totalCouponPartner",   totalCouponPartner);
	        model.addAttribute("totalNetPayout",       totalNetPayout);
	        model.addAttribute("approvedPlaceCount",   approvedPlaceCount);

	        if (!details.isEmpty()) {
	            model.addAttribute("partnerNickname", details.get(0).getNickname());
	            model.addAttribute("partnerLoginId",  details.get(0).getLoginId());
	        }

	        return "admin/settlement/detail";
	    }

	    // ─────────────────────────────────────────────
	    //  숙소별 예약 건 목록 (AJAX - 상세 페이지 아코디언)
	    //  GET /admin/settlement/orders?placeId=&month=
	    // ─────────────────────────────────────────────
	    @GetMapping("/orders")
	    @ResponseBody
	    public Object orders(
	            @RequestParam Long placeId,
	            @RequestParam String month
	    ) {
	        return settlementService.getDetailList(
	                buildFilter(null, placeId, month));
	    }

	    // ─────────────────────────────────────────────
	    //  정산 승인 - 숙소 단위
	    //  POST /admin/settlement/approve/place
	    // ─────────────────────────────────────────────
	    @PostMapping("/approve/place")
	    @ResponseBody
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
	    @ResponseBody
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
	    @ResponseBody
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
	    @ResponseBody
	    public List<SettlementOrderDto> csvPlace(
	            @RequestParam Long   placeId,
	            @RequestParam String month
	    ) {
	        SettlementFilterDto filter = new SettlementFilterDto();
	        filter.setPlaceId(placeId);
	        filter.setSettlementMonth(month);
	        return settlementService.getExcelRowsByPlace(filter);
	    }

	    // ─────────────────────────────────────────────
	    //  편의 메서드
	    // ─────────────────────────────────────────────
	    private SettlementFilterDto buildFilter(Long memberId, Long placeId, String month) {
	        SettlementFilterDto f = new SettlementFilterDto();
	        f.setMemberId(memberId);
	        f.setPlaceId(placeId);
	        f.setSettlementMonth(month);
	        return f;
	    }

}
