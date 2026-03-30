package com.tripan.app.service;

import com.tripan.app.domain.dto.TripPlaceDto;
import java.util.List;

// 나만의 장소 
public interface TripPlaceService {

    // 키워드로 장소 검색
    List<TripPlaceDto> searchPlaces(String keyword, Long currentMemberId);

    // 카카오맵 등에서 추가하여 memberId 를 반드시 기록 (나만의 장소 / NONE 카테고리)
    TripPlaceDto registerMyPlace(TripPlaceDto dto, Long memberId);

    // ★ 공용 장소 find-or-create (RESTAURANT·TOUR 등 비-NONE 카테고리)
    //   - apiContentId(kakaoId) 로 먼저 조회 → 없으면 name+address 로 조회 → 없으면 신규 삽입
    //   - member_id = NULL (공용 레코드)
    //   - 항상 apiContentId 를 채운 TripPlaceDto 반환 → 호출자가 addPlaceToDay 에 전달
    TripPlaceDto findOrCreatePublicPlace(TripPlaceDto dto);

    // 나만의 장소 목록 
    List<TripPlaceDto> getMyPlaces(Long memberId);
    
    // 나만의 장소 삭제 
    boolean deleteMyPlace(Long placeId, Long memberId);
}