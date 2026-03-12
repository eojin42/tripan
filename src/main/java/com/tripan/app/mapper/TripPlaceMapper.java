package com.tripan.app.mapper;

import com.tripan.app.domain.dto.TripDto;
import com.tripan.app.domain.dto.TripPlaceDto;
import com.tripan.app.trip.domain.entity.TripPlace;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

@Mapper
public interface TripPlaceMapper {

    // ════════════════════════════════════════════════════
    // 기존 메서드 - 워크스페이스 일정/경비/추천
    // ════════════════════════════════════════════════════

    /** 여행 전체 일정 + 장소 조회 (DayPlaceMap resultMap 사용) */
    List<TripDto.TripDayDto> findDayItemsByTripId(Long tripId);

    /** 키워드/카테고리 장소 검색 (기존 - TripPlace 엔티티 반환) */
    List<TripPlace> searchPlaces(@Param("keyword")          String keyword,
                                  @Param("category")         String category,
                                  @Param("currentMemberId") Long   currentMemberId);

    /** 공개된 여행의 장소 목록 조회 */
    List<TripPlace> findPublicTripPlaces(Long tripId);

    /** 경비 요약 (합계, 1인당 평균) */
    Map<String, Object> getExpenseSummary(Long tripId);

    /** 카테고리별 경비 */
    List<Map<String, Object>> getExpenseByCategory(Long tripId);

    /** 경비 목록 */
    List<Map<String, Object>> getExpenseList(Map<String, Object> params);

    /** 태그 기반 추천 장소 */
    List<TripDto> selectRecommendedPlaces(@Param("categoryName")    String       categoryName,
                                           @Param("tagNames")        List<String> tagNames,
                                           @Param("currentMemberId") Long         currentMemberId);

    /** 키워드 장소 검색 (TripDto 반환) */
    List<TripDto> selectPlacesByKeyword(@Param("keyword")          String keyword,
                                         @Param("currentMemberId") Long   currentMemberId);

    // ════════════════════════════════════════════════════
    // 신규 메서드 - 한국관광공사 API 연동 장소 관리
    // (TripPlaceDto 기반)
    // ════════════════════════════════════════════════════

    /** 장소 저장 (API 동기화 or 나만의 장소 등록) */
    int insertPlace(TripPlaceDto dto);

    /** API contentId 중복 체크 */
    Long findPlaceIdByApiContentId(String apiContentId);

    /** 이름+주소 중복 체크 (나만의 장소 등록 시) */
    Long findPlaceIdByNameAndAddress(@Param("placeName") String placeName,
                                     @Param("address")   String address);

    /** 카테고리별 추천 장소 (랜덤) - TripPlaceDto */
    List<TripPlaceDto> selectRecommendPlaces(@Param("category")        String category,
                                              @Param("cityList")        List<String> cityList, // 🟢 List 타입으로 변경!
                                              @Param("currentMemberId") Long   currentMemberId,
                                              @Param("limit")           int    limit);

    /** 키워드 검색 - TripPlaceDto (공용 + 내 것만) */
    List<TripPlaceDto> searchPlacesByKeyword(@Param("keyword")          String keyword,
                                              @Param("currentMemberId") Long   currentMemberId);

    /** 나만의 장소 목록 (본인 전용) */
    List<TripPlaceDto> selectMyPlaces(@Param("memberId") Long memberId);

    /** 단건 조회 */
    TripPlaceDto selectPlaceById(@Param("placeId")          Long placeId,
                                  @Param("currentMemberId") Long currentMemberId);
}
