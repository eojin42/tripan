package com.tripan.app.partner.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import com.tripan.app.partner.domain.dto.PartnerApplyDto;

@Controller
@RequestMapping("/partner")
public class PartnerController {

    @GetMapping("/apply")
    public String applyPage() {
        return "partner/apply"; 
    }

    @PostMapping("/apply")
    public String submitApply(@ModelAttribute PartnerApplyDto applyDto) {
        
        System.out.println("신청한 숙소명: " + applyDto.getPartnerName());
        System.out.println("담당자 연락처: " + applyDto.getContactPhone());

        return "redirect:/partner/waiting"; 
    }

    @GetMapping("/waiting")
    public String waitingPage() {
        return "partner/waiting";
    }
}