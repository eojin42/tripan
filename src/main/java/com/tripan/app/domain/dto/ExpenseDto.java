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

    /**
     * 지출 등록 요청
     * payer(결제자)가 지출 내용 + 분담자 목록을 함께 제출
     */
    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class CreateRequest {

        /** 어떤 여행의 지출인지 */
        private Long tripId;

        /** 실제 결제한 사람 */
        private Long payerId;

        /**
         * 지출 카테고리
         * FOOD / ACCOMMODATION / TRANSPORT / TOUR / CAFE / SHOPPING / ETC
         */
        private String category;

        /** 총 결제 금액 */
        private BigDecimal amount;

        /** 지출명 / 내용 (예: 삼겹살, 택시비) */
        private String description;

        /** 실제 지출 날짜 */
        private LocalDate expenseDate;

        /** 영수증 이미지 경로 (선택) */
        private String receiptUrl;

        /** 결제 수단 (카드 / 현금 / 계좌이체) */
        private String paymentType;

        /** 추가 메모 (선택) */
        private String memo;

        /**
         * 분담 참여자 목록
         * - 균등 분배: 모두 동일 shareAmount
         * - 비율 분배: 각자 다른 shareAmount
         */
        private List<ParticipantRequest> participants;
    }

    /** 분담 참여자 등록 요청 */
    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class ParticipantRequest {

        /**
         * 분담하는 멤버 ID
         * 외부 인원(워크스페이스 밖)은 null
         */
        private Long memberId;

        /**
         * 외부 인원 이름 (memberId == null 인 경우 사용)
         * DB expense_participant.nickname 컬럼에 저장
         */
        private String nickname;

        /** 이 멤버가 부담할 금액 */
        private BigDecimal shareAmount;
    }

    /**
     * 지출 수정 요청
     * 참여자 목록 전체 교체 방식(기존 삭제 후 재등록)
     */
    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class UpdateRequest {

        private String category;
        private BigDecimal amount;
        private String description;
        private LocalDate expenseDate;
        private String receiptUrl;
        private String paymentType;
        private String memo;

        /** 수정된 분담 참여자 목록 (전체 교체) */
        private List<ParticipantRequest> participants;
    }

    // ────────────────────────────────────────────────
    // RESPONSE DTOs
    // ────────────────────────────────────────────────

    /** 지출 목록 조회 응답 (요약) */
    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
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
    }

    /** 지출 상세 조회 응답 (분담 참여자 포함) */
    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
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

        /** 분담 참여자 목록 */
        private List<ParticipantResponse> participants;
    }

    /** 분담 참여자 응답 */
    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class ParticipantResponse {

        private Long participantId;
        private Long memberId;
        private String memberNickname;
        /** 외부 인원인 경우 이 값에 이름이 들어있음 (memberId == null) */
        private String nickname;
        private BigDecimal shareAmount;
    }

    /**
     * 여행 전체 지출 통계 응답
     * 카테고리별 합계, 1인당 부담액 등
     */
    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class TripSummaryResponse {

        private Long tripId;

        /** 총 지출 합계 */
        private BigDecimal totalAmount;

        /** 카테고리별 지출 합계 */
        private List<CategorySummary> categoryBreakdown;

        /** 멤버별 결제 합계 (누가 얼마 냈는지) */
        private List<MemberPaymentSummary> memberPayments;

        /** 멤버별 부담 합계 (누가 얼마 내야 하는지) */
        private List<MemberShareSummary> memberShares;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class CategorySummary {
        private String category;
        private BigDecimal totalAmount;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class MemberPaymentSummary {
        private Long memberId;
        private String nickname;
        /** 실제로 카드 긁은 금액 합계 */
        private BigDecimal paidAmount;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class MemberShareSummary {
        private Long memberId;
        private String nickname;
        /** 부담해야 하는 금액 합계 */
        private BigDecimal shareAmount;
        /** paidAmount - shareAmount (양수면 받을 돈, 음수면 보낼 돈) */
        private BigDecimal balance;
    }
}