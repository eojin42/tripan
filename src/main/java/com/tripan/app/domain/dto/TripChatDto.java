package com.tripan.app.domain.dto;

import lombok.Getter;
import lombok.Setter;
import lombok.Builder;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import java.util.List;

public class TripChatDto {

    /** 채팅방 정보 */
    @Getter @Setter @Builder
    @NoArgsConstructor @AllArgsConstructor
    public static class RoomResponse {
        private Long   chatRoomId;
        private Long   tripId;
        private String chatRoomName;
        private String status;
        private int    unreadCount;
        private String lastMessage;
        private String lastMessageAt;
    }

    /** 메시지 */
    @Getter @Setter @Builder
    @NoArgsConstructor @AllArgsConstructor
    public static class MessageResponse {
        private Long   messageId;
        private Long   roomId;
        private Long   memberId;
        private String nickname;
        private String profileImage;
        private String messageType;   // TALK / SYSTEM / JOIN / LEAVE
        private String content;
        private String createdAt;
        private boolean mine;         // 내가 보낸 메시지 여부 (JS에서도 판별 가능하지만 편의상)
    }

    /** 메시지 전송 요청 */
    @Getter @Setter
    public static class SendRequest {
        private String content;
        private String messageType;   // default: TALK
    }

    /** WebSocket broadcast payload */
    @Getter @Setter @Builder
    @NoArgsConstructor @AllArgsConstructor
    public static class WsMessage {
        private String type;          // NEW_MESSAGE / JOIN / LEAVE
        private Long   chatRoomId;
        private MessageResponse message;
    }
}
