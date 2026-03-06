package com.tripan.app.domain.dto;

import lombok.Data;

@Data
public class CommunityChatRoomDto {
    private Long chatRoomId;
    private String chatRoomName;
    private String chatRoomType;
    private String status;
    
    private int userCount; // 현재 접속자 수 
}