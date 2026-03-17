package com.tripan.app.admin.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Controller
@RequiredArgsConstructor
@Slf4j
@RequestMapping("/admin/partner")
public class PartnerManageController {

	@GetMapping("main")
	public String main() {
		return "admin/partner/main";
	}
	
	@GetMapping("apply")
	public String apply() {
		return "admin/partner/apply";
	}
	
	@GetMapping("manage")
	public String manage() {
		return "admin/partner/manage";
	}
	
	
}
