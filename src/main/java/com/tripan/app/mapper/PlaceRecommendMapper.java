package com.tripan.app.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.tripan.app.domain.dto.FestivalDto;
import com.tripan.app.domain.dto.PlaceDto;

@Mapper
public interface PlaceRecommendMapper {

    /** 큐레이션 목록 전용 (이미지 있는 장소만) */
    List<PlaceDto> selectCurationPlaces(
            @Param("category") String category,
            @Param("region")   String region,
            @Param("keyword")  String keyword,
            @Param("limit")    int limit,
            @Param("offset")   int offset);

    long countCurationPlaces(
            @Param("category") String category,
            @Param("region")   String region,
            @Param("keyword")  String keyword);

    List<PlaceDto> selectRecommendPlaces(
            @Param("category") String category,
            @Param("region")   String region,
            @Param("keyword")  String keyword,
            @Param("limit")    int limit,
            @Param("offset")   int offset);

    long countRecommendPlaces(
            @Param("category") String category,
            @Param("region")   String region,
            @Param("keyword")  String keyword);

    List<PlaceDto> searchPlacesByName(
            @Param("keyword")  String keyword,
            @Param("category") String category);

    PlaceDto selectPlaceDetailById(@Param("placeId") Long placeId);

    /** 주변 장소용 경량 조회 (lat/lng만, JOIN 없음 → 500 방지) */
    PlaceDto selectPlaceLatLng(@Param("placeId") Long placeId);

    List<String> selectPlaceImages(@Param("placeId") Long placeId);

    /** 축제 상세 (festival 테이블) */
    FestivalDto selectFestivalDetailByPlaceId(@Param("placeId") Long placeId);

    /** 축제 이미지 다중 조회 (festival_image 테이블) */
    List<String> selectFestivalImages(@Param("placeId") Long placeId);

    Map<String, Object> getRestaurantDetailByPlaceId(@Param("placeId") Long placeId);

    List<PlaceDto> selectNearbyPlaces(
            @Param("placeId") Long placeId,
            @Param("lat")     Double lat,
            @Param("lng")     Double lng,
            @Param("limit")   int limit);

    List<String> selectDistinctRegions();
}
