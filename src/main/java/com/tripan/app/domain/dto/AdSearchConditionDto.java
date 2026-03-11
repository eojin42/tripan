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
}
