package com.tripan.app.domain.dto;

import java.time.LocalDateTime;

import lombok.Data;

@Data
public class CommunityChatRoomDto {
    private Long chatRoomId;
    private String chatRoomName;
    private String chatRoomType;
    private String status;
    private String userName;
    
    private int userCount; // 현재 접속자 수 
    
    private Long createdBy;
    private LocalDateTime createdAt;
    private String lastMessage;
    private boolean hasUnread;
}