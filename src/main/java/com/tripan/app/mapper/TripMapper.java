package com.tripan.app.mapper;

import com.tripan.app.domain.dto.TripDto;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;

@Mapper
public interface TripMapper {

    /** 기본 여행 정보 (TO_CHAR 날짜 포함) */
    TripDto selectTripDetails(@Param("tripId") Long tripId);

    /** 동행자 목록 */
    List<TripDto.TripMemberDto> selectMembersByTripId(@Param("tripId") Long tripId);

    /** 테마 태그 목록 */
    List<String> selectTagsByTripId(@Param("tripId") Long tripId);

    /** 태그 자동완성 */
    List<String> selectTagNamesByKeyword(@Param("keyword") String keyword);

    /** 공개 여행 검색 (키워드, 기존 유지) */
    List<TripDto> selectPublicTrips(@Param("keyword") String keyword);

    /** 나의 여행 목록 (방장 + 참여 중인 여행) */
    List<TripDto> selectMyTrips(@Param("memberId") Long memberId);

    // ── 피드 전용 ──────────────────────────────────────────

    /**
     * 인기 공개 여행 TOP 8 (스크랩순)
     * feed_list.jsp 캐러셀 섹션용
     */
    List<TripDto> selectHotPublicTrips();

    /**
     * 공개 여행 전체 페이징 (무한스크롤)
     *
     * @param offset 건너뛸 행 수 (page * size)
     * @param size   한 번에 가져올 개수 (기본 12)
     */
    List<TripDto> selectPublicTripsPaged(@Param("offset") int offset, @Param("size") int size);
    /** 공개 여행 상세 (작성자 포함) */
    TripDto selectPublicTripDetail(@Param("tripId") Long tripId);

    /** 비슷한 공개 여행 TOP 4 */
    List<TripDto> selectRelatedPublicTrips(@Param("tripId") Long tripId,
                                           @Param("cityKeyword") String cityKeyword);

    /** 좋아요 수 */
    int selectTripLikeCount(@Param("tripId") Long tripId);

    /** 내가 좋아요 했는지 (0 or 1) */
    int selectMyTripLike(@Param("tripId") Long tripId, @Param("memberId") Long memberId);

    /** 좋아요 추가 */
    void insertTripLike(@Param("tripId") Long tripId, @Param("memberId") Long memberId);

    /** 좋아요 삭제 */
    void deleteTripLike(@Param("tripId") Long tripId, @Param("memberId") Long memberId);
}