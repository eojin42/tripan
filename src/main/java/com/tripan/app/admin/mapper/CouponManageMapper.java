package com.tripan.app.admin.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.tripan.app.admin.domain.dto.CouponDto;

@Mapper
public interface CouponManageMapper {

    // KPI
    CouponDto.KpiResponse selectKpi();

    // 쿠폰 목록
    List<CouponDto.ListItem> selectCouponList(Map<String, Object> params);
    int selectCouponCount(Map<String, Object> params);

    // 승인 대기 목록
    List<CouponDto.ListItem> selectPendingList();

    // 쿠폰 상세
    CouponDto.DetailResponse selectCouponDetailById(@Param("couponId") Long couponId);

    // 쿠폰 등록/수정/삭제
    void insertCoupon(CouponDto.SaveRequest req);
    void updateCoupon(@Param("couponId") Long couponId, @Param("req") CouponDto.SaveRequest req);
    void updateCouponStatus(@Param("couponId") Long couponId,
                            @Param("status") String status,
                            @Param("memo") String memo);
    void deleteCoupons(@Param("couponId") Long couponId);

    // 발급 현황
    List<CouponDto.IssuedItem> selectIssuedList(Map<String, Object> params);
    int selectIssuedCount(Map<String, Object> params);

    // 회수
    void revokeMemberCoupon(@Param("memberCouponId") Long memberCouponId);

    // 지급
    Long selectMemberIdByLoginId(@Param("loginId") String loginId);
    void insertMemberCoupon(@Param("memberId") Long memberId,
                            @Param("couponId") Long couponId);

    // 파트너 옵션
    List<CouponDto.PartnerOption> selectPartnerOptions();

    // 조건별 쿠폰/회원 조회
    List<CouponDto.ListItem> findByConditionType(@Param("conditionType") String conditionType);
    int countMembersByCondition(Map<String, Object> params);
    List<Long> findMemberIdsByCondition(Map<String, Object> params);

    // 시퀀스
    Long selectCurrentCouponId();
}