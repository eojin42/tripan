package com.tripan.app.admin.domain.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonFormat;

import lombok.Data;

public class CouponDto {

	@Data
    public static class ListItem {
        private Long couponId;
        private Long partnerId;
        private String partnerName;
        private String couponName;
        private BigDecimal discountAmount;
        private String discountType;
        private BigDecimal maxDiscountAmount;
        private BigDecimal minOrderAmount;
        private BigDecimal platformShare;
        private BigDecimal partnerShare;

        @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm")
        private LocalDateTime validFrom;

        @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm")
        private LocalDateTime validUntil;

        private String status;
        private int issuedCount;

        @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm")
        private LocalDateTime createdAt;

        private String issueConditionType;
        private String issueConditionValue;
    }

    @Data
    public static class SaveRequest {
        private String couponName;
        private BigDecimal discountAmount;
        private String discountType;
        private BigDecimal maxDiscountAmount;
        private BigDecimal minOrderAmount;
        private BigDecimal platformShare;
        private Long partnerId;

        @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm")
        private LocalDateTime validFrom;

        @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm")
        private LocalDateTime validUntil;

        // NONE / NEW_MEMBER / BOOKING_COUNT / REVIEW_COUNT / AMOUNT_SPENT
        private String issueConditionType;
        private String issueConditionValue;

        private List<CouponTargetDto> targetList;
    }

    @Data
    public static class DetailResponse {
        private Long couponId;
        private Long partnerId;
        private String partnerName;
        private String couponName;
        private BigDecimal discountAmount;
        private String discountType;
        private BigDecimal maxDiscountAmount;
        private BigDecimal minOrderAmount;
        private BigDecimal platformShare;
        private BigDecimal partnerShare;

        @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm")
        private LocalDateTime validFrom;

        @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm")
        private LocalDateTime validUntil;

        private String status;
        private String issueConditionType;
        private String issueConditionValue;

        private List<CouponTargetDto> targetList;
    }

    @Data
    public static class ReviewRequest {
        private String result;
        private String memo;
    }

    @Data
    public static class DeleteRequest {
        private List<Long> couponIds;
    }

    @Data
    public static class KpiResponse {
        private int total;
        private int platform;
        private int partner;
        private int waiting;
        private int issuedThisMonth;
        private int usedThisMonth;
    }

    @Data
    public static class PartnerOption {
        private Long partnerId;
        private String partnerName;
    }

    @Data
    public static class IssuedItem {
        private Long memberCouponId;
        private Long couponId;
        private String couponName;
        private Long partnerId;
        private String partnerName;
        private Long memberId;
        private String discountType;
        private BigDecimal discountAmount;

        @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd HH:mm:ss", timezone = "Asia/Seoul")
        private LocalDateTime issuedAt;

        @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd HH:mm:ss", timezone = "Asia/Seoul")
        private LocalDateTime validUntil;

        @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd HH:mm:ss", timezone = "Asia/Seoul")
        private LocalDateTime expiredAt;

        private String status;
    }

    @Data
    public static class PreviewCountResponse {
        private int count;
    }

    @Data
    public static class RegisterResponse {
        private Long couponId;
        private int issuedCount;
    }

    @Data
    public static class PageResponse<T> {
        private List<T> list;
        private int totalCount;
        private PaginationInfo pagination;
    }

    @Data
    public static class PaginationInfo {
        private List<Integer> pages;
        private boolean showPrev;
        private boolean showNext;
        private int firstPage;
        private int lastPage;
        private int prevBlockPage;
        private int nextBlockPage;
    }
    
    @Data
    public static class UsageItem {
        private String     couponName;             // 쿠폰명
        private String     discountType;           // FIXED / PERCENT
        private BigDecimal discountAmount;         // 총 할인금액
        private BigDecimal platformDiscountAmount; // 플랫폼 부담금액
        private BigDecimal partnerDiscountAmount;  // 파트너 부담금액
        private BigDecimal platformShare;          // 플랫폼 부담 비율
        private BigDecimal partnerShare;           // 파트너 부담 비율
    }

}