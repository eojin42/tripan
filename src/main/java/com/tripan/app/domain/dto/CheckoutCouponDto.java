package com.tripan.app.domain.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CheckoutCouponDto {
    private Long memberCouponId;    
    private Long couponId;          
    private String couponName;      
    
    private String discountType;    
    private Long discountAmount;    
    private Long minOrderAmount;    
    private Long maxDiscountAmount; 
    
    private int isApplicable;        
    private Long calculatedDiscount;    
    
    private String expiredAt;
    
    public boolean isApplicable() {
        return this.isApplicable == 1;
    }
}