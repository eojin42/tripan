package com.tripan.app.domain.dto;

import java.util.List;

import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

@Getter
@Setter
@ToString
public class AdSearchConditionDto {
	private Long memberId;	// 현재 검색하는 회원의 번호 : 찜버튼 구현
	
    private String region;
    private String checkin;
    private String checkout;
    private int adult;
    private int child;

    private Integer minPrice;
    private Integer maxPrice;
    
    private List<String> accTypes;

    private List<String> accFacilities; 
    private List<String> roomFacilities; 
    
    // 페이징 변수
    private int offset; 
    private int size; 
    
    private String sort;      // 정렬 기준 (POPULAR, NEW, PRICE_ASC, PRICE_DESC, DISTANCE)
    private Double userLat;   // 사용자 현재 위도 (거리순 정렬 시 사용)
    private Double userLng;   // 사용자 현재 경도 (거리순 정렬 시 사용)
    
    private String tag;
}
