package com.tripan.app.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.tripan.app.domain.dto.TripDto;
import com.tripan.app.domain.dto.TripDto.TripDayDto;
import com.tripan.app.trip.domain.entity.TripPlace;

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

    
    // 카테고리 및 태그 기반 장소 추천 목록 조회
    List<TripDto> selectRecommendedPlaces(
        @Param("categoryName") String categoryName, 
        @Param("tagNames") List<String> tagNames, 
        @Param("currentMemberId") Long currentMemberId
    );

    // 지도 내 장소 키워드 검색 
    List<TripDto> selectPlacesByKeyword(
        @Param("keyword") String keyword, 
        @Param("currentMemberId") Long currentMemberId
    );
    
}
