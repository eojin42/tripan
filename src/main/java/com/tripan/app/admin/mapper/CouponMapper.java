package com.tripan.app.admin.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.tripan.app.admin.domain.dto.CouponDto;

@Mapper
public interface CouponMapper {

    /* ── KPI ── */
    CouponDto.KpiResponse selectKpi();

    /* ── 쿠폰 목록 ── */
    List<CouponDto.ListItem> selectCouponList(Map<String, Object> params);
    int selectCouponCount(Map<String, Object> params);

    /* ── 승인 대기 목록 ── */
    List<CouponDto.ListItem> selectPendingList();

    /* ── 단건 조회 ── */
    CouponDto.ListItem selectCouponById(@Param("couponId") Long couponId);

    /* ── 등록 ── */
    void insertCoupon(CouponDto.SaveRequest req);

    /* ── 수정 ── */
    void updateCoupon(@Param("couponId") Long couponId, @Param("req") CouponDto.SaveRequest req);

    /* ── 승인/반려 ── */
    void updateCouponStatus(@Param("couponId") Long couponId,
                            @Param("status") String status,
                            @Param("memo") String memo);

    /* ── 삭제 ── */
    void deleteCoupons(Long couponId);

    /* ── 회원 발급 현황 ── */
    List<CouponDto.IssuedItem> selectIssuedList(Map<String, Object> params);
    int selectIssuedCount(Map<String, Object> params);

    /* ── 파트너 옵션 ── */
    List<CouponDto.PartnerOption> selectPartnerOptions();

    /* ── 엑셀용 전체 조회 ── */
    List<CouponDto.ListItem> selectCouponListForExcel(Map<String, Object> params);
    
    List<CouponDto.ListItem> findByConditionType(String conditionType);
    
    int countMembersByCondition(Map<String, Object> params);
    List<Long> findMemberIdsByCondition(Map<String, Object> params);
}