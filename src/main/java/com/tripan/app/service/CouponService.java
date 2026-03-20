package com.tripan.app.service;

import java.util.List;
import java.util.Map;

import com.tripan.app.domain.dto.CheckoutCouponDto;

public interface CouponService {
	public List<CheckoutCouponDto> getCouponsForCheckout(Long memberId, Long placeId, String roomId, long totalAmount);

	void useCoupon(Long memberCouponId, String orderId, long discountAmount, String roomId);

	void restoreCoupon(Long memberCouponId, String orderId);

	List<Map<String, Object>> getDownloadableCoupons(Long placeId, Long memberId);

	void downloadCoupon(Long memberId, Long couponId);
}
