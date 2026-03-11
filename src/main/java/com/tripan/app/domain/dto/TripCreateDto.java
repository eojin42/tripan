package com.tripan.app.domain.dto;

import java.math.BigDecimal;
import java.util.List;
import lombok.Getter;
import lombok.Setter;

@Getter @Setter
public class TripCreateDto {
    private String title;           // 여행 제목
    private String description;     // 여행 설명 (선택)
    private String tripType;        // COUPLE / FAMILY / FRIENDS / SOLO / BUSINESS (선택)

    private String startDate;       // 시작일
    private String endDate;         // 종료일
    private List<Long> regionId;
    private List<String> cities;

    private BigDecimal totalBudget; // 총 예산 (null 허용)
    private int isPublic;           // 0: 비공개, 1: 공개

    private List<String> tags;      // "#힐링", "#우정여행" 등

    /**
     * 썸네일 이미지 (선택)
     * - 프론트: FileReader.readAsDataURL() → "data:image/jpeg;base64,..." 전달
     * - null → 서버에서 기본 이미지 경로 /dist/images/logo.png 사용
     */
    private String thumbnailBase64;
}
