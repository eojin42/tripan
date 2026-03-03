package com.tripan.app.admin.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Controller
@RequiredArgsConstructor
@Slf4j
@RequestMapping("/admin")
public class HomeManageController {
	@GetMapping({"", "/", "/main"})
	public String handleHome() {
		return "admin/main/home";
	}
	
	@GetMapping("/settlement")
	public String settlement() {
		return "admin/main/settlement";
	}
	
	@GetMapping("/accomsales")
	public String accomsales() {
		return "admin/main/accomsales";
	}
}
