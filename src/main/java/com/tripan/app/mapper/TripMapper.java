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

    /** 공개 여행 검색 */
    List<TripDto> selectPublicTrips(@Param("keyword") String keyword);

    /** 나의 여행 목록 (방장 + 참여 중인 여행) */
    List<TripDto> selectMyTrips(@Param("memberId") Long memberId);
}
