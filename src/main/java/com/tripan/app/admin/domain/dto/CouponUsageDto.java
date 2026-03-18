package com.tripan.app.admin.domain.dto;

import java.math.BigDecimal;
import java.util.Date;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CouponUsageDto {
    private Long usageId;
    private String orderId;
    private Long memberCouponId;
    private Long couponId;
    private Long partnerId;
    private Long placeId;
    private BigDecimal discountAmount;
    private BigDecimal platformDiscountAmount;
    private BigDecimal partnerDiscountAmount;
    private String status;
    private Date createdAt;
    private Date cancelledAt;
    private String cancelReason;
    private Date updatedAt;

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class SaveRequest {
        private String orderId;
        private Long memberCouponId;
        private Long couponId;
        private Long partnerId;
        private Long placeId;
        private BigDecimal discountAmount;
        private BigDecimal platformDiscountAmount;
        private BigDecimal partnerDiscountAmount;
        private String status;
        private String cancelReason;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class SearchRequest {
        private String orderId;
        private Long couponId;
        private Long partnerId;
        private Long placeId;
        private String status;
        private String fromDate;
        private String toDate;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class CancelRequest {
        private Long usageId;
        private String cancelReason;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class SummaryResponse {
        private Long usageCount;
        private BigDecimal totalDiscountAmount;
        private BigDecimal totalPlatformDiscountAmount;
        private BigDecimal totalPartnerDiscountAmount;
    }
}
