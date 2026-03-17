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
            return "redirect:/partner/main"; 
        }

        Long memberId = userDetails.getMember().getMemberId();
        String status = partnerApplyService.getPartnerStatus(memberId);

        if ("edit".equals(mode)) {
            return "partner/apply/apply";
        }

        String entryPoint = "admin".equals(source) ? "ADMIN" : "MAIN";

        if ("PENDING".equals(status) || "REJECTED".equals(status)) {
            model.addAttribute("entryPoint", entryPoint); 
            model.addAttribute("partnerStatus", status);
            return "partner/apply/waiting"; 
        }

        return "partner/apply/apply";
    }

    @GetMapping("/login")
    public String partnerLoginForm(
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        
        if (userDetails != null) {
            // 🌟 이미 로그인된 파트너인 경우: /partner/main 으로 이동 (404 해결!)
            if (userDetails.getAuthorities().contains(new SimpleGrantedAuthority("ROLE_PARTNER"))) {
                return "redirect:/partner/main"; 
            } else {
                return "redirect:/partner/apply"; 
            }
        }
        return "partner/member/login"; 
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

        try {
            applyDto.setMemberId(userDetails.getMember().getMemberId()); 
            partnerApplyService.applyPartner(applyDto);
        } catch (Exception e) {
            log.error("입점 신청 중 에러 발생", e);
            rttr.addFlashAttribute("errorMsg", "신청 중 문제가 발생했습니다.");
            return "redirect:/partner/apply"; 
        }

        return "redirect:/partner/apply_complete"; 
    }

    @GetMapping("/apply_complete")
    public String completePage() {
        return "partner/apply/apply_complete"; 
    }
}