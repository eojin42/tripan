package com.tripan.app.admin.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.tripan.app.admin.domain.dto.CouponDto;

@Mapper
public interface CouponManageMapper {

    CouponDto.KpiResponse selectKpi();

    List<CouponDto.ListItem> selectCouponList(Map<String, Object> params);
    int selectCouponCount(Map<String, Object> params);

    List<CouponDto.ListItem> selectPendingList();

    CouponDto.DetailResponse selectCouponDetailById(@Param("couponId") Long couponId);

    void insertCoupon(CouponDto.SaveRequest req);

    void updateCoupon(@Param("couponId") Long couponId, @Param("req") CouponDto.SaveRequest req);

    void updateCouponStatus(@Param("couponId") Long couponId,
                            @Param("status") String status,
                            @Param("memo") String memo);

    void deleteCoupons(Long couponId);

    List<CouponDto.IssuedItem> selectIssuedList(Map<String, Object> params);
    int selectIssuedCount(Map<String, Object> params);

    List<CouponDto.PartnerOption> selectPartnerOptions();

    List<CouponDto.ListItem> selectCouponListForExcel(Map<String, Object> params);

    List<CouponDto.ListItem> findByConditionType(String conditionType);

    int countMembersByCondition(Map<String, Object> params);
    List<Long> findMemberIdsByCondition(Map<String, Object> params);

    Long selectCurrentCouponId();
}