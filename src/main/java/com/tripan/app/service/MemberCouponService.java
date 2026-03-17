package com.tripan.app.service;

import java.sql.SQLException;
import java.util.List;

import com.tripan.app.admin.domain.entity.Member1;
import com.tripan.app.domain.dto.MemberCouponDto;

public interface MemberCouponService {
	public void issueWelcomeCoupon(Member1 member1) throws Exception;
	public List<MemberCouponDto> getMyCouponList(Long memberId, String status) throws SQLException;
	public void insertCoupon(Member1 member1) throws Exception;
}
