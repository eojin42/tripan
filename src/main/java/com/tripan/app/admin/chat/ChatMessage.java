package com.tripan.app.admin.chat;

import lombok.Data;

@Data
public class ChatMessage {
	private String sender;
	private String senderName;
	private String receiver;
	private String receiverName;
	
	private String message;
}
