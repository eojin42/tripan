package com.tripan.app.domain.dto;

import lombok.*;
import java.time.LocalDateTime;
import java.util.List;

import com.tripan.app.admin.domain.dto.MemberDto;

@Getter @Setter
@Builder @NoArgsConstructor @AllArgsConstructor
public class MyPageSummaryDto {

	private MemberDto member;
	private BadgeInfoDto equippedBadge;
	
    // follow 집계
    private long followerCount;
    private long followingCount;
    private long postCount; // 게시물 수

    // 장착 배지

    // ── 여행 통계 ──
    private long totalTripCount;       // 참여한 여행 총 횟수
    private long ownedTripCount;       // 내가 만든 여행 수 (OWNER)
    private long visitedRegionCount;   // 방문 지역 수 (regionId distinct)
    private long completedTripCount;   // 완료한 여행 수
    private double avgTripDays;        // 평균 여행 기간 (일)
    private long reviewCount;          // 작성한 리뷰 수

    private List<RegionItem> visitedRegions; // 방문 지역 목록
    private List<ActivityItem> activitySummary; // 내 활동 요약

    @Getter @Setter
    @Builder @NoArgsConstructor @AllArgsConstructor
    public static class ActivityItem {
        private String activityType;  // BOOKMARK / FOLLOW / REVIEW / TRIP
        private String description;   // CONCAT으로 생성 ex) "제주 해변 호텔 찜 추가"
        private LocalDateTime actionAt;  // 각 테이블의 created_at
    }
    
    @Getter @Setter
    @Builder @NoArgsConstructor @AllArgsConstructor
    public static class RegionItem {
        private Long   regionId;
        private String regionName;
    }
}
