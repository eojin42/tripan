package com.tripan.app.domain.dto;

import lombok.Getter;
import lombok.Setter;
import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
public class TripDto {
    // 기본 여행 데이터
    private Long tripId;
    private String tripName;
    private String startDate;
    private String endDate;
    private String status;
    private String thumbnailUrl;
    private List<String> cities;          // JSP에서 사용 (List 형태)
    private String citiesStr;              // DB에서 받는 raw 문자열 ("서울, 제주")

    // 여행 생성 시 입력 필드
    private String tripType;        // COUPLE / FAMILY / FRIENDS / SOLO / BUSINESS
    private String description;     // 여행 설명
    private List<String> tags;      // 테마 태그
    private String inviteCode;      // 초대 링크 코드
    private int isPublic;           // 0: 비공개, 1: 공개

    // 통계
    private String leaderNickname;
    private String regionName;
    private Long regionId;
    private double totalBudget;
    private double currentExpense;

    // 동행자 목록
    private List<TripMemberDto> members;

    // 일정
    private List<TripDayDto> days;

    // 투표
    private List<VoteDto> votes;

    // 체크리스트
    private List<ChecklistDto> checklists;

    @Getter @Setter
    public static class TripMemberDto {
        private Long memberId;
        private String nickname;
        private String profileImage;
        private String role;               // OWNER / EDITOR / VIEWER
        private String invitationStatus;   // ACCEPTED / PENDING
    }

    @Getter @Setter
    public static class TripDayDto {
        private Long dayId;
        private int dayNumber;
        private String tripDate;
        private String dayMemo;
        private List<ItineraryItemDto> items;
    }

    @Getter @Setter
    public static class ItineraryItemDto {
        private Long itemId;
        private String visitOrder;
        private String startTime;
        private String endTime;
        private String memo;
        private Long placeId;
        private String placeName;
        private Double latitude;
        private Double longitude;
        private String category;
        private String imageUrl;
        
        private List<ItineraryImageDto> images = new ArrayList<>();
    }

    @Getter @Setter
    public static class ItineraryImageDto {
        private Long imageId;
        private String imageUrl;
        private Long memberId;
    }

    @Getter @Setter
    public static class VoteDto {
        private Long voteId;
        private String title;
        private int totalVotes;
        private List<VoteCandidateDto> candidates;
    }

    @Getter @Setter
    public static class VoteCandidateDto {
        private Long candidateId;
        private Long placeId;
        private String placeName;
        private int voteCount;
    }

    @Getter @Setter
    public static class ChecklistDto {
        private Long checklistId;
        private String itemName;
        private String category;        // 카테고리
        private boolean isChecked;
        private String checkManager;    // 담당자
    }

    @Getter @Setter
    public static class PlaceAddDto {
        private String apiPlaceId;
        private String placeName;
        private String address;
        private Double latitude;
        private Double longitude;
        private String categoryName;
        private String placeUrl;
        private boolean customPlace;
        private String created_at;
    }
}