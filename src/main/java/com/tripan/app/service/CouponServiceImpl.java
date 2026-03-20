package com.tripan.app.service;

import java.util.List;
import java.util.Map;

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
	
	@Override
    public List<Map<String, Object>> getDownloadableCoupons(Long placeId, Long memberId) {
        // 비로그인 상태일 때는 memberId를 0으로 넘겨서 목록만 보여주도록 처리
        Long mId = (memberId != null) ? memberId : 0L;
        return couponMapper.selectDownloadableCoupons(placeId, mId);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void downloadCoupon(Long memberId, Long couponId) {
        int count = couponMapper.checkCouponDownloaded(memberId, couponId);
        if (count > 0) {
            throw new RuntimeException("이미 발급받으신 쿠폰입니다.");
        }
        couponMapper.insertMemberCoupon(memberId, couponId);
    }
}
