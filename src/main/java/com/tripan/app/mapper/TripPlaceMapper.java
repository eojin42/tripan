package com.tripan.app.mapper;

import com.tripan.app.domain.dto.TripDto;
import com.tripan.app.trip.domain.entity.TripPlace;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

/**
 * TripPlaceMapper
 *
 * MyBatis XML: TripPlaceMapper.xml
 * 사용처: TripServiceImpl, PlaceApiController, ItineraryController
 */
@Mapper
public interface TripPlaceMapper {

    /** 여행의 DAY별 장소 목록 (trip_day + itinerary_item + trip_place JOIN) */
    List<TripDto.TripDayDto> findDayItemsByTripId(@Param("tripId") Long tripId);

    /** 장소 검색 (키워드 + 카테고리 필터, 나만의 장소 포함) */
    List<TripPlace> searchPlaces(
        @Param("currentMemberId") Long currentMemberId,
        @Param("keyword") String keyword,
        @Param("category") String category);

    /** 공개 여행의 장소 목록 */
    List<TripPlace> findPublicTripPlaces(@Param("tripId") Long tripId);

    /** 추천 장소 (태그/카테고리 기반) */
    List<Map<String, Object>> selectRecommendedPlaces(
        @Param("currentMemberId") Long currentMemberId,
        @Param("categoryName") String categoryName,
        @Param("tagNames") List<String> tagNames);

    /** 키워드로 장소 검색 */
    List<Map<String, Object>> selectPlacesByKeyword(
        @Param("currentMemberId") Long currentMemberId,
        @Param("keyword") String keyword);

    /** 가계부 요약 */
    Map<String, Object> getExpenseSummary(@Param("tripId") Long tripId);

    /** 카테고리별 지출 */
    List<Map<String, Object>> getExpenseByCategory(@Param("tripId") Long tripId);

    /** 지출 목록 (멤버별) */
    List<Map<String, Object>> getExpenseList(
        @Param("tripId") Long tripId,
        @Param("memberId") Long memberId);
}
