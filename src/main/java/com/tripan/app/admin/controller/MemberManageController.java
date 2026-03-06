package com.tripan.app.admin.controller;

import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;

import com.tripan.app.admin.domain.dto.BookingResponseDto;
import com.tripan.app.admin.domain.dto.DormantKpiDto;
import com.tripan.app.admin.domain.dto.DormantMemberDto;
import com.tripan.app.admin.domain.dto.MemberDto;
import com.tripan.app.admin.domain.dto.MemberKpiDto;
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
		MemberKpiDto kpi = memberService.getMemberKpi();
		model.addAttribute("kpi", kpi);
		
		List<MemberDto> memberList = memberService.getAllMembers();
		
		model.addAttribute("list", memberList);
		model.addAttribute("activePage", "members");
		
		return "admin/member/main";
	}
	
	@GetMapping("detail/{memberId}")
	public String getmemberDetail(@PathVariable("memberId") Long memberId, Model model) {
		MemberDto member = memberService.getMemberDetail(memberId);
		
		List<BookingResponseDto> bookings = bookingService.getBookingsByMember(memberId);
		
		model.addAttribute("member", member);
	    model.addAttribute("bookingList", bookings);
		return "admin/member/memberDetail";
	}
	
	@GetMapping("dormant")
	public String dormantMembers(Model model) {
		DormantKpiDto dormantKpi = memberService.getDormantKpi();
        model.addAttribute("dormantKpi", dormantKpi);
        
        DormantMemberDto dormantList = memberService.getDormantMembers();
        model.addAttribute("dormantList", dormantList);

		return "admin/member/dormantMembers";
	}
}