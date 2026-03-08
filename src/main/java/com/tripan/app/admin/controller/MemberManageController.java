package com.tripan.app.admin.controller;

import java.util.List;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;

import com.tripan.app.admin.domain.dto.BookingResponseDto;
import com.tripan.app.admin.domain.dto.DormantKpiDto;
import com.tripan.app.admin.domain.dto.DormantMemberDto;
import com.tripan.app.admin.domain.dto.MemberDto;
import com.tripan.app.admin.domain.dto.MemberKpiDto;
import com.tripan.app.admin.domain.entity.Member1;
import com.tripan.app.admin.service.BookingManageService;
import com.tripan.app.admin.service.MemberManageService;
import com.tripan.app.security.CustomUserDetails;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Controller
@Slf4j
@RequiredArgsConstructor
@RequestMapping("admin/member/*")
public class MemberManageController {
	private final MemberManageService memberService;
	private final BookingManageService bookingService;
	
	@GetMapping({"", "/", "/main"})
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
        
        List<DormantMemberDto> dormantList = memberService.getDormantMembers();
        model.addAttribute("dormantList", dormantList);

		return "admin/member/dormantMembers";
	}
	
	@PostMapping("status")
	public ResponseEntity<?> updateStatus(
	        @RequestBody MemberDto request,
	        @AuthenticationPrincipal CustomUserDetails userDetails) { 

	    if (userDetails == null) {
	        return ResponseEntity.status(401).body(Map.of("error", "세션이 만료되었습니다. 다시 로그인해주세요."));
	    }

	    Long adminId = userDetails.getMember().getMemberId(); 

	    memberService.updateMemberStatus(
	        request.getMemberId(),   // targetId
	        request.getStatusCode(), // newStatus
	        request.getMemo(),       // memo
	        adminId
	    );
	    
	    return ResponseEntity.ok(Map.of("result", "ok"));
	}
	
	@PostMapping("status/bulk")
	public ResponseEntity<?> bulkUpdateStatus(
	        @RequestBody MemberDto request,
	        @AuthenticationPrincipal CustomUserDetails userDetails) {

	    if (userDetails == null) {
	        return ResponseEntity.status(401).body(Map.of("error", "세션이 만료되었습니다. 다시 로그인해주세요."));
	    }

	    Long adminId = userDetails.getMember().getMemberId();

	    memberService.bulkUpdateStatus(
	            request.getTargetIds(), 
	            request.getStatusCode(), 
	            request.getMemo(), 
	            adminId
	    );
	    
	    return ResponseEntity.ok(Map.of("result", "ok"));
	}
	  
  @PostMapping("dormant/restore")
    public ResponseEntity<?> restoreDormant(
            @RequestBody Map<String, Object> body,
            @AuthenticationPrincipal Member1 admin) {

        Long targetId = Long.valueOf(body.get("targetId").toString());
        memberService.restoreDormantMember(targetId, admin.getId());
        return ResponseEntity.ok(Map.of("result", "ok"));
    }
  
  /*@PostMapping("dormant/mail")
  public ResponseEntity<?> sendMail(@RequestBody Map<String, Object> body) {
      memberService.sendReactivationMail((String) body.get("email"));
      return ResponseEntity.ok(Map.of("result", "ok"));
  }*/

  /*@PostMapping("dormant/mail/bulk")
  public ResponseEntity<?> bulkSendMail(@RequestBody Map<String, Object> body) {
      @SuppressWarnings("unchecked")
      List<String> emails = (List<String>) body.get("emails");
      memberService.bulkSendReactivationMail(emails);
      return ResponseEntity.ok(Map.of("result", "ok"));
  }*/
	}