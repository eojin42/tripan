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
    
    // 관광지
    private String usetime;        // 이용시간
    private String closedDays;     // 쉬는날 
    
    // 숙소
    private String checkintime;
    private String checkouttime;

    // 시스템 정보
    private LocalDateTime modifiedTime; 
    private LocalDateTime createdTime;
}