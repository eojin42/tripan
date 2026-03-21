package com.tripan.app.admin.domain.dto;

import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;

@Getter @Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ChatMessageManageDto {

    private Long   messageId;
    private Long   roomId;
    private Long   memberId;
    private String senderNickname;
    private String messageType;  // TALK, ENTER, LEAVE, SYSTEM
    private String content;
    private String createdAt;    // 화면 표시용 포맷 문자열
}