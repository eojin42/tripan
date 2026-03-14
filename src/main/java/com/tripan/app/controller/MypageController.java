package com.tripan.app.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Controller
@RequiredArgsConstructor
@Slf4j
@RequestMapping("/mypage/*")
public class MypageController {
	
	@GetMapping({"", "/", "/main"})
	public String main(Model model) {
		model.addAttribute("activeMenu", "main");
		return "mypage/main";
	}
	
	@GetMapping("schedule")
	public String schedule(Model model) {
		model.addAttribute("activeMenu", "schedule");
		return "mypage/schedule";
	}
	
	@GetMapping("bookmark")
	public String bookmark(Model model) {
		model.addAttribute("activeMenu", "bookmark");
		return "mypage/bookmark";
	}
	
	@GetMapping("review")
	public String review(Model model) {
		model.addAttribute("activeMenu", "review");
		return "mypage/review";
	}
	
	@GetMapping("coupon")
	public String coupon(Model model) {
		model.addAttribute("activeMenu", "coupon");
		return "mypage/coupon";
	}
	
	@GetMapping("map")
	public String map(Model model) {
		model.addAttribute("activeMenu", "map");
		return "mypage/map";
	}
	
}
