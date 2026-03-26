package com.tripan.app.admin.domain.dto;

import lombok.Getter;
import lombok.Setter;

@Getter 
@Setter
public class ReservationResponseDto {
	private Long   id;
    private String resId;
    private String username;
 
    /* 숙소 + 객실 */
    private String placeName;
    private String roomName;
 
    /* 날짜 */
    private String checkInDate;
    private String checkOutDate;
    private String duration;       // checkIn ~ checkOut 문자열
 
    /* 결제 금액 상세 */
    private Long   totalAmount;     // 할인 전 총 금액
    private Long   couponDiscount;  // 쿠폰 할인액
    private Long   pointDiscount;   // 포인트 사용액
    private Long   realTotalAmount; // 실결제액
    private String totalPrice;      // 화면 표시용 (₩ 포맷)
 
    /* 상태 */
    private String statusText;
    private String statusClass;
}