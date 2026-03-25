package com.tripan.app.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.tripan.app.domain.dto.PlaceDto;

@Mapper
public interface PlaceMapper {

    // ── 중복 체크 ──────────────────────────────────────────────
    Long findPlaceIdByNameAndAddress(@Param("placeName") String placeName,
                                     @Param("address")   String address);

    Long findPlaceIdByApiContentId(@Param("apiContentId") String apiContentId);

    // ── INSERT ─────────────────────────────────────────────────
    /** 일반 장소 (SEQ 기반 PK) */
    int insertPlace(PlaceDto place);

    /** KTO contentId를 PK로 직접 사용 (배치용) */
    int insertKtoPlace(PlaceDto place);

    /** 숙박 상세 (accommodation 테이블) — insertKtoPlace 후 별도 호출 */
    int insertAccommodationDetail(PlaceDto place);

    // ── 추천 장소 (무한스크롤 offset 지원) ────────────────────────
    /**
     * @param category  'all' | 'TOUR' | 'STAY' | 'RESTAURANT' | 'CULTURE' | 'LEISURE' | 'SHOPPING'
     * @param cityList  여행 도시 목록 - 빈 리스트면 전체
     *                  (KAKAO_CITIES = ["제주"] → ["제주"] / ["전라","강원"] → 두 도시 OR 조건)
     * @param limit     페이지당 건수 (기본 12)
     * @param offset    시작 위치 (0-based, 기본 0) — 무한스크롤
     */
    List<PlaceDto> selectRecommendPlaces(@Param("category") String category,
                                          @Param("cityList") List<String> cityList,
                                          @Param("limit")    int limit,
                                          @Param("offset")   int offset);

    /**
     * 전체 건수 (hasMore 판단용)
     */
    long countRecommendPlaces(@Param("category") String category,
                               @Param("cityList") List<String> cityList);

    // ── 키워드 검색 ────────────────────────────────────────────
    List<PlaceDto> searchPlacesByName(@Param("keyword") String keyword,
                                       @Param("category") String category);
    
    /** 설명이 없는 장소 50개 조회 */
    List<PlaceDto> findPlacesWithNullDescription();

    /** 장소 전화번호, 설명 업데이트 */
    int updatePlaceDetails(@Param("placeId") Long placeId, 
                           @Param("phoneNumber") String phoneNumber, 
                           @Param("description") String description);

    /** 이미지 URL 업데이트 (image_url IS NULL인 경우만) */
    int updatePlaceImage(@Param("placeId") Long placeId,
                         @Param("imageUrl") String imageUrl);

    /** 이미지 없는 장소 placeId 목록 */
    List<Long> findPlacesWithNullImage();
    
    List<Long> findRestaurantsWithoutDetails();

    int upsertRestaurant(@Param("placeId") Long placeId,
                         @Param("openTime") String openTime, @Param("restDate") String restDate,
                         @Param("parking") String parking, @Param("infoCenter") String infoCenter,
                         @Param("reservation") String reservation);

    int upsertRestaurantFacility(@Param("placeId") Long placeId,
                                 @Param("chkCreditCard") int chkCreditCard,
                                 @Param("kidsFacility") int kidsFacility,
                                 @Param("packing") int packing);

    int upsertRestaurantMenu(@Param("placeId") Long placeId,
                             @Param("firstMenu") String firstMenu, @Param("treatMenu") String treatMenu,
                             @Param("smallImageUrl") String smallImageUrl);
    
    java.util.Map<String, Object> getRestaurantDetailByPlaceId(@Param("placeId") Long placeId);
    
    int upsertPlace(PlaceDto place);
    
    List<Map<String, Object>> findAttractionsWithoutDetails();
    
    void upsertAttraction(
            @Param("placeId")    Long   placeId,
            @Param("closedDays") String closedDays,
            @Param("usetime")    String usetime
        );
}
