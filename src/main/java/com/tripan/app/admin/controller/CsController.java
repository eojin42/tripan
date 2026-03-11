package com.tripan.app.admin.controller;

import java.util.List;
import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import com.tripan.app.admin.service.CsManageService;
import com.tripan.app.domain.dto.CommunityChatRoomDto;
import com.tripan.app.domain.dto.MemberDto;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Controller
@Slf4j
@RequiredArgsConstructor
public class CsController {
	private final CsManageService csService;
	@GetMapping("/admin/cs")
	public String csmain() {
		
		return "admin/cs/main";
	}
	
	@GetMapping("/admin/inquiry") // 실제 주소: /api/admin/inquiry
    @ResponseBody
    public ResponseEntity<?> getInquiryList() {
        // List<InquiryDto> list = csService.getAllInquiries();
        // return ResponseEntity.ok(list);
        return ResponseEntity.ok().build(); // 임시
    }
	
	@GetMapping("/api/chat/rooms/support")
	@ResponseBody
    public ResponseEntity<?> getSupportRooms(HttpSession session) {
        MemberDto loginUser = (MemberDto) session.getAttribute("loginUser");
        if (loginUser == null) {
        	return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        
        List<CommunityChatRoomDto> rooms = csService.getSupportRoomsByMemberId(loginUser.getMemberId());
        return ResponseEntity.ok(rooms);
        
    }
    
    @PostMapping("/api/chat/rooms/support/create")
    @ResponseBody
    public ResponseEntity<?> createSupportRoom(HttpSession session) {
        MemberDto loginUser = (MemberDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        try {
			CommunityChatRoomDto room = csService.createSupportRoom(loginUser.getMemberId());
			return ResponseEntity.ok(room);
		} catch (Exception e) {
			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
						.body(Map.of("error",e.getMessage()));
		}
    }
    
    @PostMapping("/admin/inquiry/{id}/reply")
    @ResponseBody
    public ResponseEntity<?> replyInquiry(@PathVariable Long id, @RequestBody Map<String, String> body) {
        // csService.replyInquiry(id, body.get("reply"));
        return ResponseEntity.ok().build(); // 임시
    }

    @PostMapping("/api/chat/rooms/{roomId}/close")
    @ResponseBody
    public ResponseEntity<?> closeChatRoom(@PathVariable Long roomId) {
        // csService.closeSupportRoom(roomId);
        return ResponseEntity.ok().build(); // 임시
    }
}
