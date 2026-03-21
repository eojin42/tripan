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
public class ChatRoomManageDto {

    /* ── 채팅방 기본 정보 ── */
    private Long   chatRoomId;
    private String chatRoomName;
    private String chatRoomType;   // REGION, WORKSPACE, SUPPORT

    /* ── 지역 연결 (region 테이블 JOIN) ── */
    private Long   regionId;
    private String sidoName;
    private String sigunguName;

    /* ── 상태 ── */
    private String status;        // ACTIVE/CLOSED

    /* ── 집계/통계 ── */
    private Integer onlineCount;   // 현재 접속자 수
    private Integer unreadCount;   // 읽지 않은 메시지 수
    private String  lastMessage;   // 마지막 메시지 미리보기

    /* ── 생성 정보 ── */
    private Long          createdBy;
    private LocalDateTime createdAt;


    /* 내부 클래스 — 요청/응답 전용 DTO */

    /** 채팅방 개설 요청 */
    @Getter @Setter
    @NoArgsConstructor
    public static class CreateRequest {
        private String  chatRoomName;
        private String  chatRoomType;
        private Long    regionId;
        private String status;
    }

    /** 활성/비활성 변경 요청 */
    @Getter @Setter
    @NoArgsConstructor
    public static class StatusRequest {
        private String status;
    }

    /** 통계 응답 */
    @Getter @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class StatsResponse {
        private int total;
        private int active;
        private int onlineUsers;
        private int todayMessages;
        private int totalRegion;    // 지역 채팅방 수
        private int totalCs;        // CS 채팅방 수
        private int activeRegion;   // 활성 지역 채팅방 수
        private int activeCs;       // 활성 CS 채팅방 수
    }
}