package com.tripan.app.admin.domain.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import com.fasterxml.jackson.annotation.JsonFormat;

import lombok.Data;

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
        @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd HH:mm:ss", timezone = "Asia/Seoul")
        private LocalDateTime  validFrom;
        @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd HH:mm:ss", timezone = "Asia/Seoul")
        private LocalDateTime  validUntil;
        private String     status;
        private int        issuedCount;
        @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd HH:mm:ss", timezone = "Asia/Seoul")
        private LocalDateTime     createdAt;
        private String     issueConditionType;
        private String     issueConditionValue;
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
        @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd HH:mm:ss", timezone = "Asia/Seoul")
        private LocalDateTime  validFrom;
        @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd HH:mm:ss", timezone = "Asia/Seoul")
        private LocalDateTime  validUntil;
        private String     issueConditionType;       // 프론트에서 오는 필드명
        private String     issueConditionValue;
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
        @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd HH:mm:ss", timezone = "Asia/Seoul")
        private LocalDateTime issuedAt;
        @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd HH:mm:ss", timezone = "Asia/Seoul")
        private LocalDateTime validUntil;
        private String status;  // UNUSED | USED | CANCELED
    }
    
    /** 발급 예상 인원 응답 */
    @Data
    public static class PreviewCountResponse {
        private int count;
    }
    
    /** 쿠폰 등록 응답 (발급 인원 포함) */
    @Data
    public static class RegisterResponse {
        private Long couponId;
        private int  issuedCount;
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
