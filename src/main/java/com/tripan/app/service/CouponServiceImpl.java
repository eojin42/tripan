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
	
	@Override
    @Transactional(rollbackFor = Exception.class)
    public void restoreCoupon(Long memberCouponId, String orderId) {
        
        // 내 쿠폰함(member_coupon)의 상태를 'USED'에서 'AVAILABLE'로 변경
        couponMapper.restoreMemberCoupon(memberCouponId);
        
        // 사용 내역(coupon_usage)에 취소일자와 사유 업데이트
        couponMapper.cancelCouponUsage(orderId, memberCouponId);
    }
}
