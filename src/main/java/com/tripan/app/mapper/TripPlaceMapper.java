package com.tripan.app.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.tripan.app.domain.dto.TripDto;
import com.tripan.app.domain.dto.TripPlaceDto;
import com.tripan.app.trip.domain.entity.TripPlace;

@Mapper
public interface TripPlaceMapper {
	
    // 워크스페이스 일정 / 경비 / 공용 조회 // 

    // 여행 전체 일정 + 장소 조회 
    List<TripDto.TripDayDto> findDayItemsByTripId(Long tripId);

    // 공개된 여행의 장소 목록 조회 
    List<TripPlace> findPublicTripPlaces(Long tripId);


    //  나만의 장소 // 
    // 나만의 장소 저장 
    int insertPlace(TripPlaceDto dto);

    // 카카오 API 고유 ID로 중복 체크 
    Long findPlaceIdByApiContentId(@Param("apiContentId") String apiContentId);

    // 이름+주소로 중복 체크 (커스텀 등록 시)
    Long findPlaceIdByNameAndAddress(@Param("placeName") String placeName,
                                     @Param("address")   String address);

    // 키워드 검색 (Track 2 전용) 
    List<TripPlaceDto> searchPlacesByKeyword(@Param("keyword")          String keyword,
                                              @Param("currentMemberId") Long   currentMemberId);

    // 나만의 장소 목록
    List<TripPlaceDto> selectMyPlaces(@Param("memberId") Long memberId);

    // 단건 조회 (권한 검증 포함)
    TripPlaceDto selectPlaceById(@Param("placeId")          Long placeId,
                                  @Param("currentMemberId") Long currentMemberId);
}