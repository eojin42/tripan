package com.tripan.app.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.tripan.app.domain.dto.CheckoutCouponDto;

@Mapper
public interface CouponMapper {
    
    List<CheckoutCouponDto> selectMyCouponsForCheckout(
    	    @Param("memberId") Long memberId, 
    	    @Param("placeId") Long placeId, 
    	    @Param("roomId") String roomId, 
    	    @Param("totalAmount") long totalAmount
    	);
    
    void updateMemberCouponStatus(@Param("memberCouponId") Long memberCouponId, @Param("status") String status);
    void insertCouponUsage(
    	    @Param("orderId") String orderId, 
    	    @Param("memberCouponId") Long memberCouponId, 
    	    @Param("discountAmount") long discountAmount,
    	    @Param("roomId") String roomId
    	);
    
    // 예약 취소 관련
    
    // 쿠폰 상태 복구 
    void restoreMemberCoupon(Long memberCouponId);

    // 쿠폰 사용 내역 취소 
    void cancelCouponUsage(@Param("orderId") String orderId, @Param("memberCouponId") Long memberCouponId);
    
    List<Map<String, Object>> selectDownloadableCoupons(
            @Param("placeId") Long placeId, 
            @Param("memberId") Long memberId
    );
    
    int checkCouponDownloaded(
            @Param("memberId") Long memberId, 
            @Param("couponId") Long couponId
    );
    
    void insertMemberCoupon(
            @Param("memberId") Long memberId, 
            @Param("couponId") Long couponId
    );
    
	void updateMemberCouponToAvailable(@Param("memberCouponId") Long memberCouponId);
    void cancelCouponUsage(@Param("memberCouponId") Long memberCouponId, @Param("orderId") String orderId);
}