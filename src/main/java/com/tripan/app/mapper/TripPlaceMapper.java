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

    // 위도+경도+회원ID로 나만의 장소 중복 체크 (재등록 방지)
    Long findPlaceIdByLatLng(@Param("lat")      Double lat,
                              @Param("lng")      Double lng,
                              @Param("memberId") Long   memberId);

    // 카카오 API 고유 ID로 중복 체크 
    Long findPlaceIdByApiContentId(@Param("apiContentId") String apiContentId);

    // 이름+주소로 중복 체크 (커스텀 등록 시)
    Long findPlaceIdByNameAndAddress(@Param("placeName") String placeName,
                                     @Param("address")   String address);

    // api_place_id 로 DTO 전체 조회
    TripPlaceDto selectPlaceByApiContentId(@Param("apiContentId") String apiContentId);

    // 이름+주소+회원ID로 DTO 전체 조회
    TripPlaceDto selectPlaceByNameAndAddress(@Param("placeName") String placeName,
                                             @Param("address") String address,
                                             @Param("memberId") Long memberId);

    // 키워드 검색 
    List<TripPlaceDto> searchPlacesByKeyword(@Param("keyword")          String keyword,
                                              @Param("currentMemberId") Long   currentMemberId);

    // 나만의 장소 목록
    List<TripPlaceDto> selectMyPlaces(@Param("memberId") Long memberId);
    
    // 나만의 장소 삭제 
    int deleteMyPlace(@Param("placeId") Long placeId, 
    		@Param("memberId") Long memberId);
    
    void deleteItineraryImagesByPlaceId(Long placeId);
    void deleteItineraryItemsByPlaceId(Long placeId);

    // 단건 조회 (권한 검증 포함)
    TripPlaceDto selectPlaceById(@Param("placeId")          Long placeId,
                                  @Param("currentMemberId") Long currentMemberId);
}