package com.tripan.app.domain.dto;

import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

public class ExpenseDto {

    // ────────────────────────────────────────────────
    // REQUEST DTOs
    // ────────────────────────────────────────────────

    @Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
    public static class CreateRequest {
        private Long tripId;
        private Long payerId;
        private String category;
        private BigDecimal amount;
        private String description;
        private LocalDate expenseDate;
        private String receiptUrl;
        private String paymentType;
        private String memo;
        private List<ParticipantRequest> participants;
    }

    @Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
    public static class ParticipantRequest {
        private Long memberId;
        private String nickname;
        private BigDecimal shareAmount;
    }

    @Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
    public static class UpdateRequest {
        private String category;
        private BigDecimal amount;
        private String description;
        private LocalDate expenseDate;
        private String receiptUrl;
        private String paymentType;
        private String memo;
        private List<ParticipantRequest> participants;
    }

    // ────────────────────────────────────────────────
    // RESPONSE DTOs
    // ────────────────────────────────────────────────

    /** 지출 목록 응답 (요약) */
    @Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
    public static class SummaryResponse {
        private Long expenseId;
        private Long tripId;
        private Long payerId;
        private String payerNickname;
        private String category;
        private BigDecimal amount;
        private String description;
        private LocalDate expenseDate;
        private String paymentType;
        private LocalDateTime createdAt;
        /**
         * ★ 정산 상태: UNSETTLED / PENDING / SETTLED
         * settlement_expense_link 기반으로 MyBatis에서 계산
         */
        private String settleStatus;
        /**
         * ★ SETTLED인 경우 완료된 batch_id
         */
        private Long settledBatchId;
    }

    /** 지출 상세 응답 (분담자 포함) */
    @Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
    public static class DetailResponse {
        private Long expenseId;
        private Long tripId;
        private Long payerId;
        private String payerNickname;
        private String category;
        private BigDecimal amount;
        private String description;
        private LocalDate expenseDate;
        private String receiptUrl;
        private String paymentType;
        private String memo;
        private LocalDateTime createdAt;
        private List<ParticipantResponse> participants;
    }

    /** 분담자 응답 */
    @Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
    public static class ParticipantResponse {
        private Long participantId;
        private Long memberId;
        private String memberNickname;
        private String nickname;
        private BigDecimal shareAmount;
    }

    /** 여행 전체 통계 응답 */
    @Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
    public static class TripSummaryResponse {
        private Long tripId;
        private BigDecimal totalAmount;
        private List<CategorySummary> categoryBreakdown;
        private List<MemberPaymentSummary> memberPayments;
        private List<MemberShareSummary> memberShares;
    }

    @Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
    public static class CategorySummary {
        private String category;
        private BigDecimal totalAmount;
    }

    @Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
    public static class MemberPaymentSummary {
        private Long memberId;
        private String nickname;
        private BigDecimal paidAmount;
    }

    @Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
    public static class MemberShareSummary {
        private Long memberId;
        private String nickname;
        private BigDecimal shareAmount;
        /** paidAmount - shareAmount (양수=받을 돈, 음수=보낼 돈) */
        private BigDecimal balance;
    }
}
