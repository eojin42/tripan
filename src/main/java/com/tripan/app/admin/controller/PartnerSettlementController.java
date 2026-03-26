package com.tripan.app.admin.controller;

import java.math.BigDecimal;
import java.util.List;
 
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.tripan.app.admin.domain.dto.SettlementDetailSummaryDto;
import com.tripan.app.admin.domain.dto.SettlementFilterDto;
import com.tripan.app.admin.domain.dto.SettlementManageDto;
import com.tripan.app.admin.service.PartnerSettlementService;
 
import lombok.RequiredArgsConstructor;
 
@Controller
@RequestMapping("/admin/settlement/partner")
@RequiredArgsConstructor
public class PartnerSettlementController {
 
    private final PartnerSettlementService settlementService;
 
    //  메인 목록 페이지
    //  GET /admin/settlement/main
    @GetMapping("/main")
    public String main(Model model) {
    	
    	List<String> months = settlementService.getAvailableMonths();
        model.addAttribute("months", months);
        return "admin/partnerSettlement/main";
    }
 
    //  상세 페이지
    //  GET /admin/settlement/detail/{memberId}?month=YYYY-MM
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
 
        SettlementDetailSummaryDto summary = new SettlementDetailSummaryDto();
        summary.setMemberId(memberId);
        summary.setSettlementMonth(month);
        summary.setTotalPlaceCount(details.size());
 
        BigDecimal totalGmv            = BigDecimal.ZERO;
        BigDecimal totalCommission     = BigDecimal.ZERO;
        BigDecimal totalCouponPlatform = BigDecimal.ZERO;
        BigDecimal totalCouponPartner  = BigDecimal.ZERO;
        BigDecimal totalNetPayout      = BigDecimal.ZERO;
        int approvedPlaceCount = 0;
 
        for (SettlementManageDto d : details) {
            if (d.getTotalGmv()            != null) totalGmv            = totalGmv.add(d.getTotalGmv());
            if (d.getTotalCommission()     != null) totalCommission     = totalCommission.add(d.getTotalCommission());
            if (d.getTotalCouponPlatform() != null) totalCouponPlatform = totalCouponPlatform.add(d.getTotalCouponPlatform());
            if (d.getTotalCouponPartner()  != null) totalCouponPartner  = totalCouponPartner.add(d.getTotalCouponPartner());
            if (d.getTotalNetPayout()      != null) totalNetPayout      = totalNetPayout.add(d.getTotalNetPayout());
            if ("done".equals(d.getSettlementStatus())) approvedPlaceCount++;
        }
 
        summary.setTotalGmv(totalGmv);
        summary.setTotalCommission(totalCommission);
        summary.setTotalCouponPlatform(totalCouponPlatform);
        summary.setTotalCouponPartner(totalCouponPartner);
        summary.setTotalNetPayout(totalNetPayout);
        summary.setApprovedPlaceCount(approvedPlaceCount);
        summary.setAllApproved(!details.isEmpty() && approvedPlaceCount == details.size());
 
        if (!details.isEmpty()) {
            summary.setPartnerNickname(details.get(0).getNickname());
            summary.setPartnerLoginId(details.get(0).getLoginId());
        }
 
        model.addAttribute("summary", summary);
        model.addAttribute("details", details);
 
        return "admin/partnerSettlement/detail";
    }
}