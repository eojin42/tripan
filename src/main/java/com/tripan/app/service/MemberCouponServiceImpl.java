package com.tripan.app.service;

import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.List;

import org.springframework.stereotype.Service;

import com.tripan.app.admin.domain.dto.CouponDto;
import com.tripan.app.admin.domain.entity.Member1;
import com.tripan.app.admin.mapper.CouponMapper;
import com.tripan.app.domain.dto.MemberCouponDto;
import com.tripan.app.domain.entity.MemberCoupon;
import com.tripan.app.mapper.MemberCouponMapper;
import com.tripan.app.repository.MemberCouponRepository;

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
	public void issueWelcomeCoupon(Member1 member1) throws Exception {
		 // NEW_MEMBER 조건이고 현재 유효한 쿠폰 목록 조회
        List<CouponDto.ListItem> welcomeCoupons =
                couponMapper.findByConditionType("NEW_MEMBER");
 
        if (welcomeCoupons == null || welcomeCoupons.isEmpty()) {
            log.info("발급할 신규가입 쿠폰 없음 (member_id={})", member1.getId());
            return;
        }
 
        // 각 쿠폰을 member_coupon 에 INSERT
        for (CouponDto.ListItem coupon : welcomeCoupons) {
            MemberCoupon memberCoupon = new MemberCoupon();
            memberCoupon.setMemberId(member1.getId());
            memberCoupon.setCouponId(coupon.getCouponId());
            memberCoupon.setExpiredAt(LocalDateTime.now().plusDays(7));
            // status, issuedAt 은 엔티티/DB 기본값으로 처리됨
 
            memberCouponRepository.save(memberCoupon);
            log.info("신규가입 쿠폰 발급 완료 member_id={}, coupon_id={}",
                    member1.getId(), coupon.getCouponId());
        }
    }

	@Override
	public List<MemberCouponDto> getMyCouponList(Long memberId, String status) throws SQLException {
		
		return memberCouponMapper.getMyCouponList(memberId, status);
	}
}
