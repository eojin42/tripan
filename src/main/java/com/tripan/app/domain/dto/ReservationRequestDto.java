package com.tripan.app.domain.dto;

import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

@Getter
@Setter
@ToString
public class ReservationRequestDto {
    private String impUid;
    private String merchantUid;
    private String roomId;
    private String checkin;
    private String checkout;
    private int adult;
    private int child;
    private Long amount;
    private String request;
    private String payMethod;
    private String status;
    
    private Long memberId;
    
    private Long reservationId;
    
    private long usedPoint;        
    private Long memberCouponId;
    
}