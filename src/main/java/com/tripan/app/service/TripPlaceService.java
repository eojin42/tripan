package com.tripan.app.service;

import com.tripan.app.domain.dto.TripPlaceDto;
import java.util.List;

// 나만의 장소 
public interface TripPlaceService {

    // 키워드로 장소 검색
    List<TripPlaceDto> searchPlaces(String keyword, Long currentMemberId);

    // 카카오맵 등에서 추가하여 memberId 를 반드시 기록
    TripPlaceDto registerMyPlace(TripPlaceDto dto, Long memberId);

    // 나만의 장소 목록 
    List<TripPlaceDto> getMyPlaces(Long memberId);
}