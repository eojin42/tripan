package com.tripan.app.admin.chat;

import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;


@Controller
@RequiredArgsConstructor
@Slf4j
public class ChatController {
	private final SimpMessagingTemplate messageingTemplate;

	@GetMapping("/chat/main")
	public String handleChatMessage() {
		return "chat/main";
	}

	@MessageMapping("/chat.send")
	@SendTo("/topic/public")
	public ChatMessage sendMessage(ChatMessage message) {
		return message;
	}

	@MessageMapping("/chat.whisper")
	public void privateMessage(ChatMessage message) {
		
		messageingTemplate.convertAndSend(
			"/queue/private/" + message.getReceiver(), 
			message);
	}
}
