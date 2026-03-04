package com.tripan.app.domain.dto;

import java.util.List;

import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

@Getter
@Setter
@ToString
public class AccommodationSearchCondition {
    private String region;      // 지역
    private String checkin;     // 체크인 날짜
    private String checkout;    // 체크아웃 날짜
    private int adult;          // 성인 수
    private int child;          // 아동 수

    private Integer minPrice;   // 최소 가격
    private Integer maxPrice;   // 최대 가격
    private Integer bed;        // 침대 수
    private Integer bath;       // 욕실 수
    private List<String> amenities; // 편의시설 목록 (wifi, pool 등)
}