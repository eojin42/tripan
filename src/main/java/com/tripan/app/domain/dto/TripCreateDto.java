package com.tripan.app.domain.dto;

import java.math.BigDecimal;
import java.util.List;

import lombok.Getter;
import lombok.Setter;

@Getter @Setter
public class TripCreateDto {
    private String title;
    private String startDate; // 시작일
    private String endDate; // 종료일
    private String tripType; // 여행 유형 (커플/친구/가족 등)
    private BigDecimal totalBudget; // 총 예산 
    private Long regionId;
    private List<String> tags;    // "#힐링", "#우정여행" 등
}