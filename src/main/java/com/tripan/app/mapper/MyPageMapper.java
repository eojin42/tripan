package com.tripan.app.mapper;

import com.tripan.app.domain.dto.*;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;


@Mapper
public interface MyPageMapper {

    // 종합 요약 (Member1 + Member2 + follow 집계)
    MyPageSummaryDto selectMyPageSummary(@Param("memberId") Long memberId);

    // 여행 통계 (trip_member + trip + review 집계)
    MyPageSummaryDto selectTravelStats(@Param("memberId") Long memberId);

    // 나의 여행 지도 (trip_member JOIN trip JOIN region)
    List<MyPageSummaryDto> selectVisitedRegions(@Param("memberId") Long memberId);

    // 내 여행 일정 (trip_member JOIN trip)
    List<MyTripDto> selectMyTrips(@Param("memberId") Long memberId);

    // 내 리뷰
    List<MyReviewDto> selectMyReviews(@Param("memberId") Long memberId);

    // 찜 목록 (bookmark 테이블)
    List<BookmarkDto> selectMyBookmarks(@Param("memberId") Long memberId);

    // 배지 전체 (badge LEFT JOIN member_badge)
    List<BadgeInfoDto> selectAllBadgesWithStatus(@Param("memberId") Long memberId);

    // 팔로잉 목록
    List<FollowDto> selectFollowingList(@Param("memberId") Long memberId);

    // 팔로워 목록
    List<FollowDto> selectFollowerList(@Param("memberId") Long memberId);

    // 활동 요약 (bookmark + follow + review + trip UNION)
    List<MyPageSummaryDto> selectActivitySummary(@Param("memberId") Long memberId);
}
