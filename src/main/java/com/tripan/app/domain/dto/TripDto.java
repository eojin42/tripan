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

    // 담아오기 횟수
    private int scrapCount;

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
        private String address;
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

    // ── 날씨 응답 DTO ───────────────────────────────────────
    // GET /api/weather 응답 (WeatherServiceImpl → WeatherController)
    @Getter @Setter
    public static class WeatherResponseDto {
        private String city;
        private List<WeatherShortDayDto> shortForecast;   // 단기 D~D+3
        private List<WeatherMidDayDto>   midForecast;     // 중기 D+4~D+10
        private boolean farFuture;                        // D+11 이후면 true
        private boolean hasDistantDays;                   // 일정에 D+11 이후 포함
        private String  climateNote;                      // 평년 기온 안내 문구
    }

    @Getter @Setter
    public static class WeatherShortDayDto {
        private String date;       // "2025-04-01"
        private String dayLabel;   // "4/1 화"
        private List<WeatherHourlyItemDto> hourly;
        private Integer tmax;
        private Integer tmin;
    }

    @Getter @Setter
    public static class WeatherHourlyItemDto {
        private String  time;      // "09" (기상청 hh)
        private Integer temp;      // 기온 °C
        private String  sky;       // "맑음" / "흐림" 등
        private Integer rainProb;  // 강수 확률 %
        private String  rainType;  // "없음" / "비" / "눈" 등
    }

    @Getter @Setter
    public static class WeatherMidDayDto {
        private String  date;      // "2025-04-05"
        private String  dayLabel;  // "4/5 토"
        private String  amDesc;    // 오전 날씨
        private String  pmDesc;    // 오후 날씨
        private Integer tmax;
        private Integer tmin;
        private Integer rainProb;  // 오전/오후 중 높은 값
    }

    // ── 메모 수정 요청 DTO ───────────────────────────────────
    // PATCH /api/itinerary/{itemId}/memo 요청 바디
    @Getter @Setter
    public static class MemoUpdateDto {
        private String       memo;
        private List<String> imageBase64List;  // 새로 업로드할 이미지 (base64)
        private List<String> keepImageUrls;    // 유지할 기존 이미지 URL 목록
    }
}