package com.tripan.app.admin.domain.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ReservationDto {
	
	/* ── 목록 + 상세 공통 ── */
    private Long    reservationId;
    private String  orderId;
    private String  memberName;
    private String  placeName;      // 숙소명 (place.place_name)
    private String  roomName;       // 객실명 (room.room_name)
    private String  partnerName;
    private String  checkInDate;
    private String  checkOutDate;
    private Long    amount;
    private Long    refundAmount;
    private String  status;
    private String  paymentStatus;
 
    /* ── 상세 전용 ── */
    private Integer guestCount;
    private String  request;
    private Long    couponDiscount;
    private Long    pointDiscount;
    private Long    settlementTargetAmount;
    private Double  commissionRate;
 
    /* ── KPI 전용 ── */
    private Long totalCount;
    private Long reservedCount;
    private Long usedCount;
    private Long cancelledCount;
}
