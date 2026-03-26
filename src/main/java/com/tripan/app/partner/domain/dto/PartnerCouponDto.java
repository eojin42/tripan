package com.tripan.app.partner.domain.dto;

import lombok.Data;

@Data
public class PartnerCouponDto {
    private Long couponId;
    private String couponName;
    private String discountType;      // FIXED(정액), PERCENT(정률)
    private Double discountAmount;    // 할인 금액 또는 비율
    private Long minOrderAmount;      // 최소 주문 금액
    private String validFrom;         // 시작일 (YYYY.MM.DD)
    private String validUntil;        // 종료일 (YYYY.MM.DD)
    private String status;            // ACTIVE, WAITING, EXPIRED

    private String targetType;        // ALL(전체 숙소), PLACE(특정 숙소)
    private Long placeId;             // 특정 숙소 적용 시 숙소 ID
    private String placeName;         // 화면 표시용 숙소명 

    private int downloadCount;        // 누적 다운로드 수 
    private int useCount;             // 실제 사용 수 
    
    private Double platformShare; 	  // 쿠폰 주체 확인용
    private Integer maxQuantity; 	  // 쿠폰 최대 다운 횟수
}