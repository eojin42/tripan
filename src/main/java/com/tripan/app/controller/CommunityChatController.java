package com.tripan.app.controller;

import com.tripan.app.domain.dto.CommunityChatMessageDto;
import com.tripan.app.service.CommunityChatService;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.simp.SimpMessageSendingOperations;
import org.springframework.stereotype.Controller;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

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
}