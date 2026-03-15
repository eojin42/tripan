package com.tripan.app.admin.domain.dto;

import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDate;

public class CouponDto {

    /** 쿠폰 목록 조회용 */
    @Data
    public static class ListItem {
        private Long       couponId;
        private Long       partnerId;
        private String     partnerName;
        private String     couponName;
        private BigDecimal discountAmount;
        private String     discountType;
        private BigDecimal maxDiscountAmount;
        private BigDecimal minOrderAmount;     // 최소 주문 금액
        private BigDecimal platformShare;
        private BigDecimal partnerShare;
        private LocalDate  validFrom;
        private LocalDate  validUntil;
        private String     status;
        private int        issuedCount;
        private String     createdAt;
    }

    /** 쿠폰 등록/수정 요청 */
    @Data
    public static class SaveRequest {
        private Long       partnerId;
        private String     couponName;
        private BigDecimal discountAmount;
        private String     discountType;
        private BigDecimal maxDiscountAmount;
        private BigDecimal minOrderAmount;     // 최소 주문 금액
        private BigDecimal platformShare;
        private LocalDate  validFrom;
        private LocalDate  validUntil;
    }

    /** 승인/반려 요청 */
    @Data
    public static class ReviewRequest {
        private String result;  // ACTIVE | REJECTED
        private String memo;
    }

    /** 삭제 요청 */
    @Data
    public static class DeleteRequest {
        private java.util.List<Long> couponIds;
    }

    /** KPI 응답 */
    @Data
    public static class KpiResponse {
        private int total;
        private int platform;
        private int partner;
        private int waiting;
        private int issuedThisMonth;
        private int usedThisMonth;
    }

    /** 파트너 옵션 (select용) */
    @Data
    public static class PartnerOption {
        private Long   partnerId;
        private String partnerName;
    }

    /** 회원 발급 현황 */
    @Data
    public static class IssuedItem {
        private Long   memberCouponId;
        private Long   couponId;
        private String couponName;
        private Long   partnerId;
        private String partnerName;
        private Long   memberId;
        private String discountType;
        private BigDecimal discountAmount;
        private String issuedAt;
        private String validUntil;
        private String status;  // UNUSED | USED | CANCELED
    }

    /** 페이지네이션 포함 목록 응답 */
    @Data
    public static class PageResponse<T> {
        private java.util.List<T> list;
        private int totalCount;
        private PaginationInfo pagination;
    }

    /** 페이지네이션 정보 */
    @Data
    public static class PaginationInfo {
        private java.util.List<Integer> pages;
        private boolean showPrev;
        private boolean showNext;
        private int firstPage;
        private int lastPage;
        private int prevBlockPage;
        private int nextBlockPage;
    }
}
