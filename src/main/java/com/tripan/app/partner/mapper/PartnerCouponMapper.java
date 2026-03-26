package com.tripan.app.partner.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.tripan.app.partner.domain.dto.PartnerCouponDto;

@Mapper
public interface PartnerCouponMapper {
    
    List<PartnerCouponDto> selectCouponList(Map<String, Object> params);
    
    Map<String, Object> selectCouponKpiStats(Long partnerId);
    
    int insertCoupon(PartnerCouponDto dto);
    
    int insertCouponTarget(Map<String, Object> targetMap);
    
    int updateCouponStatus(@Param("couponId") Long couponId, @Param("status") String status);
}