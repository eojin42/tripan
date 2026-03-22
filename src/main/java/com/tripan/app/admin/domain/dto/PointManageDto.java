package com.tripan.app.admin.domain.dto;

import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter @Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PointManageDto {

    /* ── 회원 포인트 요약 (목록용) ── */
    private Long   memberId;
    private String loginId;
    private String nickname;
    private String email;
    private int    remPoint;      // 현재 잔여 포인트
    private int    totalEarned;   // 누적 적립
    private int    totalUsed;     // 누적 사용
    private String lastChangeDate; // 마지막 변경일

    /* ── 포인트 내역 (개인 상세용) ── */
    @Getter @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class HistoryDto {
        private Long   pointId;
        private Long   memberId;
        private String orderId;
        private String changeReason;  // 적립, 사용, 관리자지급, 만료, 회수 등
        private int    pointAmount;   // 변동 포인트 (양수=적립, 음수=차감)
        private int    remPoint;      // 변동 후 잔여
        private String regDate;       // 날짜 포맷 문자열
    }

    /* ── 포인트 지급/차감 요청 ── */
    @Getter @Setter
    @NoArgsConstructor
    public static class AdjustRequest {
        private List<Long> memberIds;   // 대상 회원 PK 목록 (일괄 시 여러 개)
        private int        pointAmount; // 양수=지급, 음수=차감
        private String     changeReason;
    }

    /* ── 검색 조건 ── */
    @Getter @Setter
    @NoArgsConstructor
    public static class SearchRequest {
        private String keyword;      // 닉네임 or 아이디 검색
        private String startDate;
        private String endDate;
    }
}