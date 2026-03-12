package com.tripan.app.mapper;

import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.ibatis.annotations.Mapper;

import com.tripan.app.domain.dto.BadgeInfoDto;
import com.tripan.app.domain.dto.BookmarkDto;
import com.tripan.app.domain.dto.FollowDto;
import com.tripan.app.domain.dto.MyPageSummaryDto;
import com.tripan.app.domain.dto.MyPageSummaryDto.ActivityItem;
import com.tripan.app.domain.dto.MyReviewDto;
import com.tripan.app.domain.dto.MyTripDto;


@Mapper
public interface MyPageMapper {

    // 종합 요약 (Member1 + Member2 + follow 집계)
    MyPageSummaryDto selectMyPageSummary(Long memberId);

    // 여행 통계 (trip_member + trip + review 집계)
    MyPageSummaryDto selectTravelStats(Long memberId);

    // 나의 여행 지도 (trip_member JOIN trip JOIN region)
    List<MyPageSummaryDto> selectVisitedRegions(Long memberId);
    Set<Long> selectVisitedRegionIds(Long memberId);

    // 내 여행 일정 (trip_member JOIN trip)
    List<MyTripDto> selectMyTrips(Long memberId);

    // 내 리뷰
    List<MyReviewDto> selectMyReviews(Long memberId);

    // 찜 목록 (bookmark 테이블)
    List<BookmarkDto> selectMyBookmarks(Long memberId, String type);

    // 배지 전체 (badge LEFT JOIN member_badge)
    List<BadgeInfoDto> selectAllBadgesWithStatus(Long memberId);

    // 팔로잉 목록
    List<FollowDto> selectFollowingList(Long memberId);

    // 팔로워 목록
    List<FollowDto> selectFollowerList(Long memberId);

    // 활동 요약 (bookmark + follow + review + trip UNION)
    List<ActivityItem> selectActivitySummary(Long memberId);
    
 // 방문 시도 이름 목록(완료여행+수동등록)
    List<String> selectVisitedSidoNames(Long memberId);
    List<String> selectManualVisitedSidos(Long memberId);
    void insertUserVisitedRegion(Map<String, Object> params);
    void deleteUserVisitedRegion(Map<String, Object> params);
}
