package com.tripan.app.service;

import java.util.List;

import com.tripan.app.domain.dto.CheckoutCouponDto;

public interface CouponService {
	public List<CheckoutCouponDto> getCouponsForCheckout(Long memberId, Long placeId, String roomId, long totalAmount);

	void useCoupon(Long memberCouponId, String orderId, long discountAmount, String roomId);
}
