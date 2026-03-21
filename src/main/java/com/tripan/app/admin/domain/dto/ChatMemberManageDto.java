package com.tripan.app.admin.domain.dto;

import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;

import java.time.LocalDateTime;

@Getter @Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ChatMemberManageDto {

    private Long   chatMemberId;
    private Long   chatRoomId;
    private Long   memberId;
    private String nickname;

    private String connStatus;   // ONLINE, OFFLINE
    private String adminStatus;  // NORMAL, KICKED, BLOCKED

    private LocalDateTime joinedAt;
    private LocalDateTime lastConnectedAt;
}