package com.tripan.app.service;

import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;

import com.tripan.app.admin.domain.dto.CouponDto;
import com.tripan.app.admin.domain.entity.Member1;
import com.tripan.app.admin.mapper.CouponMapper;
import com.tripan.app.domain.dto.MemberCouponDto;
import com.tripan.app.domain.entity.MemberCoupon;
import com.tripan.app.mapper.MemberCouponMapper;
import com.tripan.app.repository.MemberCouponRepository;

import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@Slf4j
@RequiredArgsConstructor
public class MemberCouponServiceImpl implements MemberCouponService{
	private final CouponMapper couponMapper;
	private final MemberCouponMapper memberCouponMapper;
	private final MemberCouponRepository memberCouponRepository;
	
	@Override
	@Transactional
	public void issueWelcomeCoupon(Member1 member1) throws Exception {
		 // NEW_MEMBER 조건이고 현재 유효한 쿠폰 목록 조회
        List<CouponDto.ListItem> welcomeCoupons =
                couponMapper.findByConditionType("NEW_MEMBER");
 
        if (welcomeCoupons == null || welcomeCoupons.isEmpty()) {
            log.info("발급할 신규가입 쿠폰 없음 (member_id={})", member1.getId());
            return;
        }
        
        for (CouponDto.ListItem coupon : welcomeCoupons) {
            MemberCoupon memberCoupon = new MemberCoupon();
            memberCoupon.setMemberId(member1.getId());
            memberCoupon.setCouponId(coupon.getCouponId());
            memberCoupon.setExpiredAt(LocalDateTime.now().plusDays(7));
 
            memberCouponRepository.save(memberCoupon);
            log.info("신규가입 쿠폰 발급 완료 member_id={}, coupon_id={}",
                    member1.getId(), coupon.getCouponId());
        }
    }

	@Override
	public List<MemberCouponDto> getMyCouponList(Long memberId, String status) throws SQLException {
		
		return memberCouponMapper.getMyCouponList(memberId, status);
	}

	@Transactional
	@Override
	public void insertCoupon(Member1 member1) throws Exception {
		 List<CouponDto.ListItem> coupons = couponMapper.findByConditionType("NONE");
		 Map<String, Object> params = new HashMap<>();
		 params.put("conditionType", "NONE");
		 List<Long> allMemberIds = couponMapper.findMemberIdsByCondition(params);
		 
		 for (Long memberId : allMemberIds) {
		        for (CouponDto.ListItem coupon : coupons) {
		            MemberCoupon memberCoupon = new MemberCoupon();
		            memberCoupon.setMemberId(memberId);
		            memberCoupon.setCouponId(coupon.getCouponId());
		            memberCoupon.setExpiredAt(coupon.getValidUntil());
		            
		            memberCouponRepository.save(memberCoupon);
		        }
		      log.info("회원 ID {}에게 쿠폰 {}종 발급 완료", memberId, coupons.size());
		    }
	}
}
