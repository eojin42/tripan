package com.tripan.app.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.tripan.app.domain.entity.MemberCoupon;

public interface MemberCouponRepository extends JpaRepository<MemberCoupon, Long>{

}
