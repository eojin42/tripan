package com.tripan.app.admin.domain.dto;

import java.time.LocalDateTime;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class AdminChatRoomDto {
	private Long chatRoomId;
    private String chatRoomName;
    private String chatRoomType;
    private String status;
    private String userName;
    
    private int userCount; 
    private Long createdBy;
    private LocalDateTime createdAt;
    private String lastMessage;
	private int unreadCount;
}
