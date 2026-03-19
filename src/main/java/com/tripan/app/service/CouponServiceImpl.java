package com.tripan.app.service;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.tripan.app.domain.dto.CheckoutCouponDto;
import com.tripan.app.mapper.CouponMapper2;

import lombok.RequiredArgsConstructor;

@Service("userCouponService")
@RequiredArgsConstructor
public class CouponServiceImpl implements CouponService{
	private final CouponMapper2 couponMapper;

	@Override
	public List<CheckoutCouponDto> getCouponsForCheckout(Long memberId, Long placeId, String roomId, long totalAmount) {
		return couponMapper.selectMyCouponsForCheckout(memberId, placeId, roomId, totalAmount);
	}
	
	@Override
	@Transactional(rollbackFor = Exception.class)
	public void useCoupon(Long memberCouponId, String orderId, long discountAmount, String roomId) {
	    couponMapper.updateMemberCouponStatus(memberCouponId, "USED");
	    couponMapper.insertCouponUsage(orderId, memberCouponId, discountAmount, roomId);
	}

}
