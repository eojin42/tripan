package com.tripan.app.domain.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class MemberCouponDto {
	private Long memberCouponId;
	private Long memberId;
	private Long couponId;
	private String status;
	private String issuedAt;
	private String expiredAt;
	private String couponName;
	private String discountAmount;
}
