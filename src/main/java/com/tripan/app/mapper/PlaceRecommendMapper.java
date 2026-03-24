package com.tripan.app.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.tripan.app.domain.dto.PlaceDto;

/**
 * 장소 추천 / 검색 / 상세 관련 MyBatis 매퍼
 */
@Mapper
public interface PlaceRecommendMapper {

    /**
     * 카테고리 + 지역 기반 장소 목록 (무한스크롤)
     * region을 List에서 String으로 변경했습니다.
     */
    List<PlaceDto> selectRecommendPlaces(
            @Param("category") String category,
            @Param("region")   String region,  // 🔥 List<String> -> String 으로 변경
            @Param("keyword")  String keyword, // 🔥 키워드 파라미터 추가
            @Param("limit")    int limit,
            @Param("offset")   int offset);

    /**
     * 총 건수
     */
    long countRecommendPlaces(
            @Param("category") String category,
            @Param("region")   String region,  // 🔥 List<String> -> String 으로 변경
            @Param("keyword")  String keyword); // 🔥 키워드 파라미터 추가

    /**
     * 키워드 + 카테고리 검색
     */
    List<PlaceDto> searchPlacesByName(
            @Param("keyword")  String keyword,
            @Param("category") String category);

    /**
     * 장소 상세 (placeId 사용)
     */
    PlaceDto selectPlaceDetailById(@Param("placeId") Long placeId);

    /**
     * 장소 이미지 목록
     */
    List<String> selectPlaceImages(@Param("placeId") Long placeId);

    /**
     * 식당 상세
     */
    Map<String, Object> getRestaurantDetailByPlaceId(@Param("placeId") Long placeId);

    /**
     * 주변 장소
     */
    List<PlaceDto> selectNearbyPlaces(
            @Param("placeId") Long placeId,
            @Param("lat")     Double lat,
            @Param("lng")     Double lng,
            @Param("limit")   int limit);

    /**
     * 시/도 목록 (사이드바용)
     */
    List<String> selectDistinctRegions();
}