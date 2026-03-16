package com.tripan.app.mapper;

import java.sql.SQLException;
import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.tripan.app.domain.dto.MemberCouponDto;

@Mapper
public interface MemberCouponMapper {
	public void insertMemberCoupon(Map<String, Object> params);
	public List<MemberCouponDto> getMyCouponList(@Param("memberId") Long memberId, @Param("status") String status) throws SQLException;
}
