package com.tripan.app.controller;

import org.springframework.stereotype.Controller;
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
	public String main() {
		return "mypage/main";
	}
	
	@GetMapping("schedule")
	public String schedule() {
		return "mypage/schedule";
	}
	
	@GetMapping("bookmark")
	public String bookmark() {
		return "mypage/bookmark";
	}
	
	@GetMapping("review")
	public String review() {
		return "mypage/review";
	}
	
	@GetMapping("coupon")
	public String coupon() {
		return "mypage/coupon";
	}
	
	
}
