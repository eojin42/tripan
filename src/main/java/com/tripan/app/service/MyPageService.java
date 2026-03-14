package com.tripan.app.service;
import java.util.List;
import java.util.Map;
import java.util.Set;

import com.tripan.app.domain.dto.BadgeInfoDto;
import com.tripan.app.domain.dto.BookmarkDto;
import com.tripan.app.domain.dto.ConquestMapDto;
import com.tripan.app.domain.dto.FollowDto;
import com.tripan.app.domain.dto.MemberDto;
import com.tripan.app.domain.dto.MyPageSummaryDto;
import com.tripan.app.domain.dto.MyReviewDto;

/**
 * 마이페이지 서비스 인터페이스
 */
public interface MyPageService {

    // 종합 요약 (프로필 + 팔로우 통계 + 배지)
    MyPageSummaryDto getMyPageSummary(Long memberId);

    // 여행 통계
    MyPageSummaryDto getTravelStats(Long memberId);

    // 나의 여행 지도
    List<MyPageSummaryDto> getVisitedRegions(Long memberId);
    Set<Long> getVisitedRegionIds(Long memberId);  // JSP 조건 렌더링용

    // 내 리뷰 (숙소팀 테이블)
    List<MyReviewDto> getMyReviews(Long memberId);
    void deleteReview(Long memberId, Long reviewId);

    // 찜 (bookmark)
    List<BookmarkDto> getMyBookmarks(Long memberId, String type);
    void deleteBookmark(Long memberId, Long bookmarkId);

    // 배지 & 칭호
    List<BadgeInfoDto> getMyBadges(Long memberId);
    void updateEquippedBadge(Long memberId, Long badgeId);
    
    // 내 예약
    List<Map<String, Object>> getMyBookings(Long memberId) ;

    // 팔로우/팔로잉
    List<FollowDto> getFollowingList(Long memberId);
    List<FollowDto> getFollowerList(Long memberId);
    void unfollow(Long followerId, Long followingId);

    // 프로필 수정
    void updateProfile(Long memberId, MemberDto dto);

    // 활동 요약
    List<MyPageSummaryDto.ActivityItem> getActivitySummary(Long memberId);
    
    // 방문 시도 (여행지도)
    
    List<ConquestMapDto> getVisitedRegionsData(Long memberId);
    void saveVisitedRegion(ConquestMapDto dto); // 등록 및 수정 처리
    void deleteVisitedRegion(Long memberId, String sigunguName);
    
    void savePhoto(Long memberId, Long conquestMapId, String photoUrl);
    void deletePhoto(Long memberId, Long photoId);
}
