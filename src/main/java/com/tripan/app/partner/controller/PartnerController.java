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
        return "partner/apply/apply"; 
    }

    @PostMapping("/apply")
    public String submitApply(@ModelAttribute PartnerApplyDto applyDto) {
        return "redirect:/partner/apply_complete"; 
    }

    @GetMapping("/apply_complete")
    public String completePage() {
        return "partner/apply/apply_complete";
    }
}