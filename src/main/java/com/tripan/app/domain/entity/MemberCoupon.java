package com.tripan.app.domain.entity;

import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.SequenceGenerator;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MemberCoupon {
	@Id 
	@SequenceGenerator(name="MEMBER_COUPON_SEQ_GEN", sequenceName="MEMBER_COUPON_SEQ", allocationSize=1)
    @GeneratedValue(strategy=GenerationType.SEQUENCE, generator="MEMBER_COUPON_SEQ_GEN")
    @Column(name = "member_coupon_id")
    private Long memberCouponId;

    @Column(name = "member_id", nullable = false)
    private Long memberId;

    @Column(name = "coupon_id") 
    private Long couponId;

    @Column(name = "issued_at", nullable = false, updatable = false)
    private LocalDateTime issuedAt = LocalDateTime.now();

    @Column(name = "expired_at")
    private LocalDateTime expiredAt;
}
