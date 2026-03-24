package com.tripan.app.admin.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import com.tripan.app.admin.service.BannerService;
import com.tripan.app.admin.service.MagazineService;

import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/admin/curation")
@RequiredArgsConstructor
public class CurationController {
	private final BannerService bannerService;
    private final MagazineService magazineService;
 
    @GetMapping("")
    public String index(Model model) {
        model.addAttribute("banners",  bannerService.getAll());
        model.addAttribute("articles", magazineService.getAll());
        return "admin/banner/main";
    }
}