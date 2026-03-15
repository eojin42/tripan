package com.tripan.app.admin.service;

import java.util.List;

import com.tripan.app.admin.domain.dto.CouponDto;

public interface CouponService {
	 public CouponDto.KpiResponse getKpi();
	 public CouponDto.PageResponse<CouponDto.ListItem> getCouponList(
	            int page, String discountType, String status, String issuer, String keyword);
	 
	 public List<CouponDto.ListItem> getPendingList() ;
	 public void registerCoupon(CouponDto.SaveRequest req);
	 public void updateCoupon(Long couponId, CouponDto.SaveRequest req);
	 public void reviewCoupon(Long couponId, CouponDto.ReviewRequest req);
	 public void deleteCoupons(List<Long> couponIds) ;
	 public CouponDto.PageResponse<CouponDto.IssuedItem> getIssuedList(
	            int page, String status, String couponKeyword, String memberKeyword);
	 public List<CouponDto.PartnerOption> getPartnerOptions();
}
