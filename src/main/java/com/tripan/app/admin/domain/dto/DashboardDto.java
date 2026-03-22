package com.tripan.app.admin.domain.dto;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.List;

public class DashboardDto {

    /** 최근 7일 일별 예약 추이 (차트) */
    @Getter @Setter @NoArgsConstructor
    public static class DailyOrderDto {
        private String day;          // MM/DD
        private int    orderCount;   // 예약 건수
        private long   totalAmount;  // 매출액
    }

    /** 실시간 숙소 랭킹 (예약 건수 기준, 최근 30일) */
    @Getter @Setter @NoArgsConstructor
    public static class AccomRankDto {
        private int    rank;
        private Long   placeId;
        private String placeName;
        private String address;
        private String imageUrl;
        private int    reservationCount;
    }

    /** 지역 랭킹 (일정 생성 수 기준) */
    @Getter @Setter @NoArgsConstructor
    public static class RegionRankDto {
        private int    rank;
        private Long   regionId;
        private String regionName;  // sido_name
        private int    tripCount;
    }

    /** 미답변 CS 채팅 */
    @Getter @Setter @NoArgsConstructor
    public static class UnAnsweredChatDto {
        private Long   roomId;
        private String memberNickname;
        private String lastMessage;
        private String createdAt;    // 문의 생성일시
        private long   waitingHours; // 몇 시간째 미답변
    }

    /** 입점 승인 대기 파트너 */
    @Getter @Setter @NoArgsConstructor
    public static class PendingPartnerDto {
        private Long   memberId;
        private String loginId;
        private String username;
        private String email;
        private String regDate;      // 신청일
    }

    /** 신고 상위 유저 */
    @Getter @Setter @NoArgsConstructor
    public static class TopReportedDto {
        private Long   memberId;
        private String nickname;
        private String loginId;
        private int    reportCount;
        private int    statusCode;   // 1=정상, 2=정지
    }

    /** 대시보드 전체 응답 */
    @Getter @Setter @NoArgsConstructor
    public static class PageResponse {
        private List<DailyOrderDto>    dailyOrders;
        private List<AccomRankDto>     accomRanking;
        private List<RegionRankDto>    regionRanking;
        private List<UnAnsweredChatDto> unAnsweredChats;
        private List<PendingPartnerDto> pendingPartners;
        private List<TopReportedDto>    topReported;
    }
}