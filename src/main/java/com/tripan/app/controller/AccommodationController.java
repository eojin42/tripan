package com.tripan.app.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/accommodation/*")
public class AccommodationController {
	
	@GetMapping("main")
	public String main() {
		
		return "accommodation/home";
	}
	
	@GetMapping("list")
	public String list() {
		return "accommodation/list";
	}
	
}
