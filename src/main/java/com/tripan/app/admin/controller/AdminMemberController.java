package com.tripan.app.admin.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Controller
@Slf4j
@RequiredArgsConstructor
@RequestMapping("admin/member/*")
public class AdminMemberController {
	
	
	@GetMapping("main")
	public String membermain() {
		
		return "admin/member/member";
	}
	
	@GetMapping("detail")
	public String memberDetail() {
		
		return "admin/member/memberDetail";
	}
	
	@GetMapping("dormant")
	public String dormantMembers() {
		
		return "admin/member/dormantMembers";
	}
}
