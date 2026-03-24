package com.tripan.app.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.tripan.app.admin.service.MagazineService;

import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor
@RequestMapping("/curation")
public class MagazineController {
	private final MagazineService magazineService;

    @GetMapping("/magazine_list")
    public String magazine_list(Model model) {
        model.addAttribute("articles", magazineService.getPublished());
        return "curation/magazine_list";
    }

    @GetMapping("/magazine_detail")
    public String magazine_detail(@RequestParam(name="articleId") int articleId, Model model) {
        model.addAttribute("article", magazineService.getDetail(articleId));
        return "curation/magazine_detail";
    }
}
