package com.tripan.app.service;

import com.tripan.app.domain.dto.TripPlaceDto;
import java.util.List;

public interface TripPlaceService {

    /**
     * 한국관광공사 API → DB 동기화 배치
     * 매일 새벽 3시 자동 실행 + 수동 트리거 가능
     * contentTypeId 대상: 12(관광지), 14(문화시설), 32(숙박), 38(쇼핑), 39(음식점), 28(레포츠)
     */
    void syncPlacesBatch();

    /**
     * 카테고리별 추천 장소 (랜덤)
     * @param category        TOUR / STAY / RESTAURANT / CULTURE / LEISURE / SHOPPING / all
     * @param cityKeyword     여행지 도시명 (예: "부산", "제주")
     * @param currentMemberId 현재 로그인 유저 (권한 제어)
     * @param limit           반환 개수
     */
    List<TripPlaceDto> getRecommendPlaces(String category, String cityKeyword,
                                           Long currentMemberId, int limit);

    /**
     * 키워드로 장소 검색
     * - 공용 + 내 나만의 장소만 노출
     */
    List<TripPlaceDto> searchPlaces(String keyword, Long currentMemberId);

    /**
     * 나만의 장소 등록
     * - memberId 를 반드시 기록 → 타인 검색 결과에서 제외
     */
    TripPlaceDto registerMyPlace(TripPlaceDto dto, Long memberId);

    /**
     * 나만의 장소 목록 (본인 전용)
     */
    List<TripPlaceDto> getMyPlaces(Long memberId);
}
