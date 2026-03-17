package com.tripan.app.partner.controller;

import com.tripan.app.partner.domain.dto.PartnerApplyDto;
import com.tripan.app.partner.service.PartnerApplyService; 
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Slf4j
@Controller
@RequestMapping("/partner")
@RequiredArgsConstructor
public class PartnerApplyController {

    private final PartnerApplyService partnerApplyService;

    @GetMapping("/apply")
    public String applyForm() {
        return "partner/apply/apply";
    }

    @PostMapping("/apply")
    public String submitApply(@ModelAttribute PartnerApplyDto applyDto) {
        log.info("입점 신청 접수: 스테이명 = {}, 첨부파일 수 = {}", 
                 applyDto.getPartnerName(), 
                 (applyDto.getBizLicenseFiles() != null ? applyDto.getBizLicenseFiles().size() : 0));

        try {
            applyDto.setMemberId(1L); 

            partnerApplyService.applyPartner(applyDto);
            
        } catch (Exception e) {
            log.error("입점 신청 중 에러 발생", e);
            return "redirect:/partner/apply?error=true";
        }

        return "redirect:/partner/apply_complete"; 
    }

    @GetMapping("/apply_complete")
    public String completePage() {
        return "partner/apply/apply_complete"; 
    }
}