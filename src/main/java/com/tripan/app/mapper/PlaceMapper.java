package com.tripan.app.mapper;

import java.util.List;

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
    List<PlaceDto> searchPlacesByName(@Param("keyword") String keyword);
}
