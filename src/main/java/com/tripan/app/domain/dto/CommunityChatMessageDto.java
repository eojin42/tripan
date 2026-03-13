package com.tripan.app.domain.dto;

import lombok.Data;

@Data
public class CommunityChatMessageDto {
    private Long roomId;          // 채팅방 번호
    private Long memberId;        // 보낸 사람 PK
    private String senderNickname; // 보낸 사람 닉네임
    private String senderRole;     // 보낸 사람 권한 (ROLE_USER, ROLE_ADMIN)
    private String content;       // 메시지 내용
    private String messageType;   // TALK(대화), ENTER(입장), LEAVE(퇴장)
    private String createdAt;     // 작성 시간 (포맷팅된 문자열)
    private String msgDate;		  // 날짜 구분용 (YYYY-MM-DD, 히스토리 전용)
}
