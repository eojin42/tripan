package com.tripan.app.admin.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import com.tripan.app.admin.domain.dto.MemberDto;
import com.tripan.app.admin.domain.entity.Member1;
import com.tripan.app.admin.service.BookingManageService;
import com.tripan.app.admin.service.MemberManageService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Controller
@Slf4j
@RequiredArgsConstructor
@RequestMapping("admin/member/*")
public class MemberManageController {
	private final MemberManageService memberService;
	private final BookingManageService bookingService;
	
	@GetMapping("main")
	public String membermain(Model model) {
		List<MemberDto> memberList = memberService.getAllMembers();
		
		model.addAttribute("list", memberList);
		model.addAttribute("activePage", "members");
		
		return "admin/member/main";
	}
	
	@GetMapping("detail/{memberId}")
	@ResponseBody
	public ResponseEntity<?> getmemberDetail(@PathVariable Long memberId) {
		MemberDto member = memberService.getMemberDetail(memberId);
		return ResponseEntity.ok(member);
	}
	
	@GetMapping("dormant")
	public String dormantMembers() {
		
		return "admin/member/dormantMembers";
	}
}