package com.tripan.app.admin.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor
@RequestMapping("/admin/coupon/*")
public class CouponManageController {

	@GetMapping("main")
	public String main() {
		return "admin/coupon/main";
	}
	
	
}
