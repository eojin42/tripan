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
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.tripan.app.domain.dto.CommunityChatMessageDto;
import com.tripan.app.domain.dto.CommunityChatRoomDto;
import com.tripan.app.domain.dto.MemberDto;
import com.tripan.app.service.CommunityChatService;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor
public class CommunityChatController {

    private final SimpMessageSendingOperations messagingTemplate;
    private final CommunityChatService chatService;

    @MessageMapping("/chat/message")
    public void message(CommunityChatMessageDto message) {
        
        String now = LocalDateTime.now().format(DateTimeFormatter.ofPattern("a h:mm"));
        message.setCreatedAt(now);

        chatService.saveMessage(message);

        messagingTemplate.convertAndSend("/sub/chat/room/" + message.getRoomId(), message);
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