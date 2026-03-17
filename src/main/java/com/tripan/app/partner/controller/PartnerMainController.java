package com.tripan.app.partner.controller;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.tripan.app.security.CustomUserDetails;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Controller
@RequestMapping("/partner")
@RequiredArgsConstructor
public class PartnerMainController {

    @GetMapping("/main")
    public String partnerMain(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @RequestParam(value = "tab", defaultValue = "dashboard") String tab, 
            RedirectAttributes rttr,
            Model model) {

        if (userDetails == null) {
            rttr.addFlashAttribute("msg", "로그인이 필요합니다.");
            return "redirect:/partner/login";
        }

        if (!userDetails.getAuthorities().contains(new SimpleGrantedAuthority("ROLE_PARTNER"))) {
            rttr.addFlashAttribute("msg", "정식 파트너만 접근 가능한 페이지입니다.");
            return "redirect:/partner/apply";
        }

        model.addAttribute("activeTab", tab);

        return "partner/main"; 
    }
}