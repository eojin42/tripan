package com.tripan.app.domain.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class AccommodationDto {
	private Long placeId;             // PLACE 테이블
    private String name;              // PLACE_NAME
    private String imageUrl;          // PLACE 테이블의 IMAGE_URL
    private String region;            // ADDRESS를 가공해서 쓸 지역명
    private String accommodationType; // ACCOMMODATION 테이블
    private Integer minPrice;         // ROOM 테이블에서 해당 숙소의 최저가
    
    private Double latitude;
    private Double longitude;
    
    private int isBookmarked;
    
    private int reviewCount;
    private int bookmarkCount;
    
    private Integer isActive;
    
}
