package com.tripan.app.admin.domain.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CouponTargetDto {

    private Long targetId;       // target_id
    private Long couponId;       // coupon_id
    private Long partnerId;
    private Long placeId;
    private String targetType;   // ACC_TYPE / ACCOMMODATION / ROOM
    private String targetValue;  // accommodation_type / place_id / room_id
    private String isExclude;    // Y / N
}