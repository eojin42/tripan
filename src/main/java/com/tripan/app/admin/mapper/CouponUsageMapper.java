package com.tripan.app.admin.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.tripan.app.admin.domain.dto.CouponUsageDto;

import java.util.List;

@Mapper
public interface CouponUsageMapper {

    int insertCouponUsage(CouponUsageDto dto);

    int updateCouponUsageStatus(@Param("usageId") Long usageId,
                                @Param("status") String status,
                                @Param("cancelReason") String cancelReason);

    CouponUsageDto selectCouponUsageById(@Param("usageId") Long usageId);

    CouponUsageDto selectCouponUsageByOrderId(@Param("orderId") String orderId);

    List<CouponUsageDto> selectCouponUsageList(CouponUsageDto.SearchRequest request);

    CouponUsageDto.SummaryResponse selectCouponUsageSummary(CouponUsageDto.SearchRequest request);
}