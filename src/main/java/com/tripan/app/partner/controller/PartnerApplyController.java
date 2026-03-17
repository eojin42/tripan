package com.tripan.app.partner.controller;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.tripan.app.partner.domain.dto.PartnerApplyDto;
import com.tripan.app.partner.service.PartnerApplyService;
import com.tripan.app.security.CustomUserDetails;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Controller
@RequestMapping("/partner")
@RequiredArgsConstructor
public class PartnerApplyController {

    private final PartnerApplyService partnerApplyService;

    @GetMapping("/apply")
    public String applyForm(
            @AuthenticationPrincipal CustomUserDetails userDetails, 
            @RequestParam(value = "mode", required = false) String mode, 
            @RequestParam(value = "source", required = false) String source, 
            RedirectAttributes rttr,
            Model model) { 

        if (userDetails == null) {
            rttr.addFlashAttribute("msg", "로그인이 필요한 서비스입니다.");
            return "redirect:/login"; 
        }

        if (userDetails.getAuthorities().contains(new SimpleGrantedAuthority("ROLE_PARTNER"))) {
            rttr.addFlashAttribute("msg", "이미 파트너로 등록되어 있습니다. 관리자 페이지로 이동합니다.");
            return "redirect:/partner/admin/dashboard";
        }

        Long memberId = userDetails.getMember().getMemberId();
        String status = partnerApplyService.getPartnerStatus(memberId);

        if ("edit".equals(mode)) {
            return "partner/apply/apply";
        }

        String entryPoint = "admin".equals(source) ? "ADMIN" : "MAIN";

        if ("PENDING".equals(status)) {
            model.addAttribute("entryPoint", entryPoint); 
            model.addAttribute("partnerStatus", status);
            return "partner/apply/waiting"; 
        } else if ("REJECTED".equals(status)) {
            model.addAttribute("entryPoint", entryPoint); 
            model.addAttribute("partnerStatus", status);
            return "partner/apply/waiting";
        }

        return "partner/apply/apply";
    }

    @PostMapping("/apply")
    public String submitApply(
            @ModelAttribute PartnerApplyDto applyDto, 
            @AuthenticationPrincipal CustomUserDetails userDetails,
            RedirectAttributes rttr) {
        
        if (userDetails == null) {
            rttr.addFlashAttribute("msg", "로그인이 필요합니다.");
            return "redirect:/login";
        }

        log.info("입점 신청 접수: 스테이명 = {}, 첨부파일 수 = {}", 
                 applyDto.getPartnerName(), 
                 (applyDto.getBizLicenseFiles() != null ? applyDto.getBizLicenseFiles().size() : 0));

        try {
            Long currentMemberId = userDetails.getMember().getMemberId();
            applyDto.setMemberId(currentMemberId); 

            partnerApplyService.applyPartner(applyDto);
            
        } catch (Exception e) {
            log.error("입점 신청 중 에러 발생", e);
            rttr.addFlashAttribute("errorMsg", "신청 중 문제가 발생했습니다. 다시 시도해주세요.");
            return "redirect:/partner/apply"; 
        }

        return "redirect:/partner/apply_complete"; 
    }

    @GetMapping("/apply_complete")
    public String completePage() {
        return "partner/apply/apply_complete"; 
    }
    
    @GetMapping("/login")
    public String partnerLoginForm(
            @AuthenticationPrincipal CustomUserDetails userDetails, 
            RedirectAttributes rttr) {
        
        if (userDetails != null) {
            if (userDetails.getAuthorities().contains(new SimpleGrantedAuthority("ROLE_PARTNER"))) {
                return "redirect:/partner/admin/dashboard"; 
            } else {
                return "redirect:/partner/apply"; 
            }
        }
        
        return "partner/member/login"; 
    }

    
    
}