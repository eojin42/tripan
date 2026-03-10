package com.tripan.app.mapper;

import com.tripan.app.domain.dto.TripDto.TripDayDto;
import com.tripan.app.trip.domian.entity.TripPlace;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

@Mapper
public interface TripPlaceMapper {

    // 지도 마커 + 폴리라인용 - 일차별 장소 계층 조회
    List<TripDayDto> findDayItemsByTripId(@Param("tripId") Long tripId);

    // 장소 검색 (권한 필터링: 공용 or 내 장소만)
    List<TripPlace> searchPlaces(@Param("keyword") String keyword,
                                 @Param("category") String category,
                                 @Param("currentMemberId") Long currentMemberId);

    // 공개 여행 장소 조회 (다른 사람이 볼 때)
    List<TripPlace> findPublicTripPlaces(@Param("tripId") Long tripId);

    // 가계부 통계
    Map<String, Object> getExpenseSummary(@Param("tripId") Long tripId);
    List<Map<String, Object>> getExpenseByCategory(@Param("tripId") Long tripId);
    List<Map<String, Object>> getExpenseList(@Param("tripId") Long tripId,
                                             @Param("memberId") Long memberId);
}
