package com.tripan.app.admin.controller;

import java.math.BigDecimal;
import java.util.List;
 
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
 
import com.tripan.app.admin.domain.dto.SettlementFilterDto;
import com.tripan.app.admin.domain.dto.SettlementManageDto;
import com.tripan.app.admin.service.PartnerSettlementService;
 
import lombok.RequiredArgsConstructor;
 
@Controller
@RequestMapping("/admin/settlement/partner")
@RequiredArgsConstructor
public class PartnerSettlementController {
 
    private final PartnerSettlementService settlementService;
 
    // ─────────────────────────────────────────────
    //  메인 목록 페이지
    //  GET /admin/settlement/main
    // ─────────────────────────────────────────────
    @GetMapping("/main")
    public String main() {
        return "admin/partnerSettlement/main";
    }
 
    // ─────────────────────────────────────────────
    //  상세 페이지
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
            if ("DONE".equals(d.getSettlementStatus())) approvedPlaceCount++;
        }
 
        model.addAttribute("memberId",           memberId);
        model.addAttribute("settlementMonth",     month);
        model.addAttribute("details",             details);
        model.addAttribute("totalGmv",            totalGmv);
        model.addAttribute("totalCommission",     totalCommission);
        model.addAttribute("totalCouponPlatform", totalCouponPlatform);
        model.addAttribute("totalCouponPartner",  totalCouponPartner);
        model.addAttribute("totalNetPayout",      totalNetPayout);
        model.addAttribute("approvedPlaceCount",  approvedPlaceCount);
 
        if (!details.isEmpty()) {
            model.addAttribute("partnerNickname", details.get(0).getNickname());
            model.addAttribute("partnerLoginId",  details.get(0).getLoginId());
        }
 
        return "admin/partnerSettlement/detail";
    }
}