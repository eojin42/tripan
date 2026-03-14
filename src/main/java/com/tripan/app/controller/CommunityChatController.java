package com.tripan.app.controller;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.simp.SimpMessageSendingOperations;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.tripan.app.admin.service.CsManageService;
import com.tripan.app.domain.dto.CommunityChatMessageDto;
import com.tripan.app.domain.dto.CommunityChatRoomDto;
import com.tripan.app.domain.dto.MemberDto;
import com.tripan.app.service.CommunityChatService;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Controller
@RequiredArgsConstructor
@Slf4j
public class CommunityChatController {

    private final SimpMessageSendingOperations messagingTemplate;
    private final CommunityChatService chatService;
    private final CsManageService csService;

    @MessageMapping("/chat/message")
    public void message(CommunityChatMessageDto message) {

        String now = LocalDateTime.now().format(DateTimeFormatter.ofPattern("a h:mm"));
        message.setCreatedAt(now);
        
        String roomType = null;

        try {
            chatService.saveMessage(message);
            
            roomType = chatService.getRoomType(message.getRoomId());
            if ("SUPPORT".equals(roomType)) {
            	if (!"SYSTEM".equals(message.getMessageType()) && !"CLOSED".equals(message.getMessageType())) {
                    csService.reopenRoomIfClosed(message.getRoomId()); 
                } 
            }
        } catch (Exception e) {
            log.error("메시지 저장 실패 - roomId: {}, memberId: {}, error: {}",
                message.getRoomId(), message.getMemberId(), e.getMessage(), e);
        }

        messagingTemplate.convertAndSend("/sub/chat/room/" + message.getRoomId(), message);
     
        // SUPPORT 방 메시지 → 관리자 실시간 배지 업데이트
        if ("SUPPORT".equals(roomType)) {
            messagingTemplate.convertAndSend("/sub/admin/chat/message", Map.of(
                "roomId",  message.getRoomId(),
                "content", message.getContent() != null ? message.getContent() : "",
                "memberId", message.getMemberId() != null ? message.getMemberId() : 0
            ));
        }
    }
    
    @GetMapping("/api/chat/rooms/region")
    @ResponseBody
    public List<CommunityChatRoomDto> getRegionRooms() {
        return chatService.getRegionRooms();
    }

    @GetMapping("/api/chat/rooms/private")
    @ResponseBody
    public ResponseEntity<?> getMyPrivateRooms(HttpSession session) {
        MemberDto loginUser = (MemberDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            return ResponseEntity.status(401).build();
        }
        return ResponseEntity.ok(chatService.getMyPrivateRooms(loginUser.getMemberId()));
    }
    
    @GetMapping("/api/chat/history/{roomId}")
    @ResponseBody
    public ResponseEntity<?> getChatHistory(@PathVariable("roomId") Long roomId, HttpSession session) {
        MemberDto loginUser = (MemberDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            return ResponseEntity.status(401).build();
        }
        return ResponseEntity.ok(chatService.getChatHistory(roomId));
    }

    @PostMapping("/api/chat/private")
    @ResponseBody
    public ResponseEntity<?> startPrivateChat(@RequestParam("targetId") Long targetId, HttpSession session) {
        MemberDto loginUser = (MemberDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            return ResponseEntity.status(401).body(Map.of("message", "로그인이 필요합니다."));
        }
        
        try {
            Long roomId = chatService.getOrMakePrivateChat(loginUser.getMemberId(), targetId);
            return ResponseEntity.ok(Map.of("roomId", roomId));
        } catch (Exception e) {
            return ResponseEntity.status(500).body(Map.of("message", "채팅방 생성 중 오류 발생"));
        }
    }
    
    
}