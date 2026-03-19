package com.tripan.app.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.tripan.app.domain.dto.CheckoutCouponDto;

@Mapper
public interface CouponMapper2 {
    
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
}