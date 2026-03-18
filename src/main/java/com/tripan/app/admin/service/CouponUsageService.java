package com.tripan.app.admin.service;

import java.util.List;

import com.tripan.app.admin.domain.dto.CouponUsageDto;

public interface CouponUsageService {
	Long createCouponUsage(CouponUsageDto.SaveRequest request);

    void cancelCouponUsage(CouponUsageDto.CancelRequest request);

    CouponUsageDto getCouponUsage(Long usageId);

    CouponUsageDto getCouponUsageByOrderId(String orderId);

    List<CouponUsageDto> getCouponUsageList(CouponUsageDto.SearchRequest request);

    CouponUsageDto.SummaryResponse getCouponUsageSummary(CouponUsageDto.SearchRequest request);
}
