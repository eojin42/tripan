package com.tripan.app.admin.controller;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.simp.SimpMessageSendingOperations;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseBody;

import com.tripan.app.admin.service.CsManageService;
import com.tripan.app.domain.dto.AdminChatRoomDto;
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
    private final SimpMessageSendingOperations messagingTemplate;

    @GetMapping("/admin/cs")
    public String csmain() {
        return "admin/cs/main";
    }

    @GetMapping("/admin/inquiry")
    @ResponseBody
    public ResponseEntity<?> getInquiryList() {
        return ResponseEntity.ok(List.of());
    }

    /**
     * 유저용: 본인의 상담 방 목록
     * 어드민이 마이페이지에서 호출하면 → 안읽은 방만, userName 포함한 AdminChatRoomDto 반환
     */
    @GetMapping("/api/chat/rooms/support")
    @ResponseBody
    public ResponseEntity<?> getSupportRooms(HttpSession session) {
        MemberDto loginUser = (MemberDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        if ("ROLE_ADMIN".equals(loginUser.getRole())) {
            List<AdminChatRoomDto> unread = csService.getAllSupportRooms()
                    .stream()
                    .filter(r -> r.getUnreadCount() > 0)
                    .collect(Collectors.toList());
            return ResponseEntity.ok(unread);
        }
        List<CommunityChatRoomDto> rooms = csService.getSupportRoomsByMemberId(loginUser.getMemberId());
        return ResponseEntity.ok(rooms);
    }

    /** 유저용: 상담 방 생성 + 관리자에게 WebSocket 알림 */
    @PostMapping("/api/chat/rooms/support/create")
    @ResponseBody
    public ResponseEntity<?> createSupportRoom(HttpSession session) {
        MemberDto loginUser = (MemberDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        try {
            CommunityChatRoomDto room = csService.createSupportRoom(loginUser.getMemberId());

            Map<String, Object> notification = Map.of(
                "roomId",   room.getChatRoomId(),
                "userName", loginUser.getNickname() != null ? loginUser.getNickname() : loginUser.getUsername()
            );
            messagingTemplate.convertAndSend("/sub/admin/chat/new", notification);

            return ResponseEntity.ok(room);
        } catch (Exception e) {
            log.error("상담 방 생성 실패: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", e.getMessage()));
        }
    }

    /** 관리자용: 전체 상담 방 목록 (어드민 CS 페이지) */
    @GetMapping("/admin/cs/api/chat/rooms/support")
    @ResponseBody
    public ResponseEntity<?> getAllSupportRooms(HttpSession session) {
        MemberDto loginUser = (MemberDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        List<AdminChatRoomDto> rooms = csService.getAllSupportRooms();
        return ResponseEntity.ok(rooms);
    }

    /** 관리자가 채팅방 입장 시 미읽음 초기화 */
    @PutMapping("/admin/cs/api/chat/rooms/{roomId}/read")
    @ResponseBody
    public ResponseEntity<?> markRoomAsRead(@PathVariable Long roomId, HttpSession session) {
        MemberDto loginUser = (MemberDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        csService.markRoomAsRead(roomId, loginUser.getMemberId());
        return ResponseEntity.ok().build();
    }

    /** 상담 종료 (관리자) */
    @PostMapping("/api/chat/rooms/{roomId}/close")
    @ResponseBody
    public ResponseEntity<?> closeChatRoom(@PathVariable Long roomId, HttpSession session) {
        MemberDto loginUser = (MemberDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        try {
            csService.closeRoom(roomId);
            messagingTemplate.convertAndSend("/sub/chat/room/" + roomId + "/closed", Map.of("roomId", roomId));
            return ResponseEntity.ok(Map.of("message", "상담이 종료되었습니다."));
        } catch (Exception e) {
            log.error("상담 종료 실패: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", e.getMessage()));
        }
    }

    @PostMapping("/admin/inquiry/{id}/reply")
    @ResponseBody
    public ResponseEntity<?> replyInquiry(@PathVariable Long id, @RequestBody Map<String, String> body) {
        return ResponseEntity.ok().build();
    }
}
