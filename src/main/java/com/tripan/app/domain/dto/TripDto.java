package com.tripan.app.domain.dto;

import lombok.Getter;
import lombok.Setter;
import java.util.List;

@Getter
@Setter
public class TripDto {
    //  기본 여행 데이터 
    private Long tripId;
    private String tripName;
    private String startDate;
    private String endDate;
    private String status;
    private String thumbnailUrl;

    // 통계 및 단일 부가 데이터
    private String leaderNickname;  
    private String regionName;      
    private double totalBudget;     // 설정한 총 예산
    private double currentExpense;  // 현재까지 쓴 지출 총합

    // 동행자 목록 (trip_member + member 테이블)
    private List<TripMemberDto> members;

    // 여행 일정표 (일자별 방문 장소 계층 구조)
    private List<TripDayDto> days; 

    // 진행 중인 투표 현황 (vote + vote_candidate 테이블)
    private List<VoteDto> votes;

    // 준비물 공용 체크리스트 (trip_checklist 테이블)
    private List<ChecklistDto> checklists;

    @Getter @Setter
    public static class TripMemberDto {
        private Long memberId;
        private String nickname;
        private String profileImage;
        private String role; // OWNER(방장), EDITOR(편집자), VIEWER(뷰어)
    }

    @Getter @Setter
    public static class TripDayDto {
        private Long dayId;
        private int dayNumber; 
        private String tripDate;
        private String dayMemo; // 그날의 메모
        private List<ItineraryItemDto> items; 
    }

    @Getter @Setter
    public static class ItineraryItemDto {
        private Long itemId;
        private String visitOrder; 
        private String startTime;
        private String endTime;
        private String memo; // 브레이크타임 등 장소별 개별 메모
        
        // 장소(Place) 요약 정보
        private Long placeId;
        private String placeName;
        private Double latitude;
        private Double longitude;
        private String category; 
        private String imageUrl;
    }

    @Getter @Setter
    public static class VoteDto {
        private Long voteId;
        private String title; 
        private int totalVotes; // 총 참여 투표 수
        // 투표 후보지 목록 및 각각의 득표수
        private List<VoteCandidateDto> candidates; 
    }

    @Getter @Setter
    public static class VoteCandidateDto {
        private Long candidateId;
        private Long placeId;
        private String placeName; // 후보 장소명
        private int voteCount;    // 이 후보가 받은 표 수
    }

    @Getter @Setter
    public static class ChecklistDto {
        private Long checklistId;
        private String itemName;  // 예: "여권", "상비약"
        private boolean isChecked;// 체크 여부 (0/1)
        private String checkManager; // 담당자 이름 (null이면 공용)
    }
}