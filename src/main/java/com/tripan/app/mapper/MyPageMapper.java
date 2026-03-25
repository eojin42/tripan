package com.tripan.app.mapper;

import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.tripan.app.domain.dto.BadgeInfoDto;
import com.tripan.app.domain.dto.BookmarkDto;
import com.tripan.app.domain.dto.ConquestMapDto;
import com.tripan.app.domain.dto.FollowDto;
import com.tripan.app.domain.dto.MyPageSummaryDto;
import com.tripan.app.domain.dto.MyPageSummaryDto.ActivityItem;
import com.tripan.app.domain.dto.MyReviewDto;


@Mapper
public interface MyPageMapper {

    // 종합 요약 (Member1 + Member2 + follow 집계)
    MyPageSummaryDto selectMyPageSummary(Long memberId);

    // 여행 통계 (trip_member + trip + review 집계)
    MyPageSummaryDto selectTravelStats(Long memberId);

    // 나의 여행 지도 (trip_member JOIN trip JOIN region)
    List<MyPageSummaryDto> selectVisitedRegions(Long memberId);
    Set<Long> selectVisitedRegionIds(Long memberId);

    // 내 리뷰
    List<MyReviewDto> selectMyReviews(Long memberId);

    // 찜 목록 (bookmark 테이블)
    List<BookmarkDto> selectMyBookmarks(@Param("memberId") Long memberId, @Param("type") String type);

    // 배지 전체 (badge LEFT JOIN member_badge)
    List<BadgeInfoDto> selectAllBadgesWithStatus(Long memberId);

    // 팔로잉 목록
    List<FollowDto> selectFollowingList(Long memberId);

    // 팔로워 목록
    List<FollowDto> selectFollowerList(Long memberId);

    // 활동 요약 (bookmark + follow + review + trip UNION)
    List<ActivityItem> selectActivitySummary(Long memberId);
    
    // 예약 일정
    List<Map<String, Object>> getMyBookings(Long memberId);
    
    // ---지도정복---
    
    // 지역 이름("강남구")으로 region_id(101) 찾기
    Long selectRegionIdByName(String sigunguName);
    
    // 내 지도 데이터 전체 조회
    List<ConquestMapDto> selectVisitedRegionsData(Long memberId);
    
    // 해당 지역에 이미 기록이 있는지 확인 (regionId 기준)
    int checkRegionExists(@Param("memberId") Long memberId, @Param("regionId") Long regionId);
    
    // 기록 등록/수정/삭제
    void insertRegionData(ConquestMapDto dto);
    void updateRegionData(ConquestMapDto dto);
    void deleteRegionData(@Param("memberId") Long memberId, @Param("regionId") Long regionId);

    void insertPhoto(ConquestMapDto dto);
    int  deletePhoto(@Param("photoId")   Long photoId, @Param("memberId")  Long memberId);

    // update 케이스에서 사진 저장용 conquestMapId 조회
    Long selectConquestMapId(@Param("memberId") Long memberId, @Param("regionId") Long regionId);

    // 사진 목록 조회 (resultMap collection에서 호출)
    List<ConquestMapDto> selectPhotosByConquestMapId(Long conquestMapId);
}
