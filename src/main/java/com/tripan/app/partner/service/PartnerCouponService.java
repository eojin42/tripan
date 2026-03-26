package com.tripan.app.partner.service;

import java.util.List;
import java.util.Map;

import com.tripan.app.partner.domain.dto.PartnerCouponDto;

public interface PartnerCouponService {
    
    List<PartnerCouponDto> getCouponList(Map<String, Object> searchParams);
    
    Map<String, Object> getCouponKpiStats(Long partnerId);
    void createPartnerCoupon(PartnerCouponDto dto, Long partnerId, String targetPlaceId);
    
    void stopCoupon(Long couponId);
}