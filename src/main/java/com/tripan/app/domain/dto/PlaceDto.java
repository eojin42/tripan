package com.tripan.app.domain.dto;

import java.time.LocalDateTime;
import java.util.List;

import lombok.Data;

@Data
public class PlaceDto {
    
    // 공통 정보 (place 테이블)
    private Long placeId;         
    private Long partnerId;       
    private String placeName;      // 장소명
    private String category;       // 카테고리 
    private String address;        // 주소
    private Double latitude;       // 위도
    private Double longitude;      // 경도
    private String phoneNumber;    // 전화번호
    private String description;    // 개요
    private String imageUrl;       // 썸네일 이미지
    
    private List<String> images;
    
    //지역 필터링을 위한 도시명
    private String city; 

    // 하위 카테고리 상세 정보 
    // 식당
    private String opentime;       // 영업시간
    private String restdate;       // 쉬는날
    private String parking;        // 주차시설
    // 식당 부가정보 (restaurant_facility)
    private Integer chkcreditcardfood; // 신용카드 (0/1)
    private Integer kidsfacility;      // 키즈존 (0/1)
    private Integer packing;           // 포장 (0/1)
    // 메뉴 (menu)
    private String firstmenu;      // 대표메뉴
    private String treatmenu;      // 취급메뉴
    
    // 관광지
    private String usetime;        // 이용시간
    private String closedDays;     // 쉬는날 
    
    // 숙소
    private String checkintime;
    private String checkouttime;
    private String accommodationType;  // 숙소 유형
    private String parkinglodging;     // 주차 안내
    private String afId;               // accommodation_facility FK
    // 숙소 시설 (accommodation_facility)
    private Integer fitness;           // 피트니스
    private Integer chkcooking;        // 취사
    private Integer subfacility;       // 부대시설
    private Integer barbecue;          // 바베큐
    private Integer beverage;          // 식음료
    private Integer karaoke;           // 노래방
    private Integer publicpc;          // PC방
    private Integer sauna;             // 사우나

    // 시스템 정보
    private LocalDateTime modifiedTime; 
    private LocalDateTime createdTime;

    // 통계 (조회수 / 좋아요)
    private Long viewCount;
    private Long likeCount;
}