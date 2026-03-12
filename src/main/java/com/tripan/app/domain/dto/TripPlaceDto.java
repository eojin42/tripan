package com.tripan.app.domain.dto;

import lombok.Data;
import java.util.List;

/**
 * 장소 검색 결과 DTO
 * - 한국관광공사 API 결과 / DB 저장 / 나만의 장소 통합
 *
 * contentTypeId 코드표 (매뉴얼 기준):
 *   12: 관광지  14: 문화시설  15: 축제공연행사
 *   25: 여행코스  28: 레포츠  32: 숙박  38: 쇼핑  39: 음식점
 */
@Data
public class TripPlaceDto {

	private Long    placeId;       // trip_place.trip_place_id (DB PK)
    private Long    memberId;      // NULL=공용, 값있음=나만의 장소
    private String  apiContentId;  // trip_place.api_place_id (API 고유ID)
    private String  placeName;     // 장소명
    private String  address;       // 주소
    private Double  latitude;      // 위도
    private Double  longitude;     // 경도
    private String  category;      // trip_place.category_name (ATTRACTION/ACCOMMODATION/RESTAURANT/NONE)
    private String  imageUrl;      // trip_place.place_url (이미지 또는 지도 URL)
    private Boolean isCustom;      // true = 나만의 장소

    // KTO API 응답 전용 (DB 저장 안 함)
    private String  phone;
    private Integer contentTypeId;
    private String  overview;
    private String  homepage;

    // 화면 출력용
    private List<String> imageList;

}
