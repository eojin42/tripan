package com.tripan.app.domain.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

public class SettlementDto {

    // ────────────────────────────────────────────────
    // REQUEST DTOs
    // ────────────────────────────────────────────────

    /**
     * 정산 일괄 생성 요청
     * 여행이 끝난 후, expense + expense_participant 기반으로 정산 계산 후 저장
     */
    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class CreateBatchRequest {

        /** 정산 대상 여행 ID */
        private Long tripId;

        /**
         * 정산 묶음 ID (batch_id)
         * 총대 정산 / 일괄 정산 등을 그룹으로 묶을 때 사용
         * null이면 자동 생성
         */
        private Long batchId;
    }

    /**
     * 개별 정산 송금 완료 처리 요청
     * 실제 계좌이체/카카오페이 등 송금 후 완료 처리 시 사용
     */
    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class CompleteRequest {

        /** 완료 처리할 settlement ID 목록 (여러 건 한 번에 가능) */
        private List<Long> settlementIds;
    }

    // ────────────────────────────────────────────────
    // RESPONSE DTOs
    // ────────────────────────────────────────────────

    /** 정산 단건 응답 */
    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class Response {

        private Long settlementId;
        private Long tripId;

        /** 돈 보내는 사람 */
        private Long fromMemberId;
        private String fromMemberNickname;

        /** 돈 받는 사람 */
        private Long toMemberId;
        private String toMemberNickname;

        /** 송금해야 하는 금액 */
        private BigDecimal amount;

        /** PENDING / COMPLETED */
        private String status;

        /** 정산 묶음 ID */
        private Long batchId;

        /** 정산 완료 시각 */
        private LocalDateTime settledAt;

        private LocalDateTime createdAt;
    }

    /**
     * 여행 전체 정산 현황 응답
     * "나"를 기준으로 받을 돈 / 보낼 돈 분리
     */
    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class TripSettlementResponse {

        private Long tripId;

        /** 전체 정산 목록 */
        private List<Response> settlements;

        /** 내가 받아야 하는 총액 */
        private BigDecimal totalToReceive;

        /** 내가 보내야 하는 총액 */
        private BigDecimal totalToSend;

        /** 미완료 정산 수 */
        private int pendingCount;

        /** 완료 정산 수 */
        private int completedCount;
    }

    /**
     * 정산 계산 미리보기 응답
     * 실제 settlement 저장 전, 계산 결과를 미리 보여줄 때 사용
     */
    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class PreviewResponse {

        private Long tripId;

        /** 계산된 정산 목록 (DB 미저장 상태) */
        private List<SettlementDetail> details;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class SettlementDetail {

        private Long fromMemberId;
        private String fromMemberNickname;

        private Long toMemberId;
        private String toMemberNickname;

        private BigDecimal amount;
    }
    
    @Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
    public static class SingleRequest {
        private Long tripId;
        private Long toMemberId;    // creditor = 나 (요청 보내는 사람)
        private Long fromMemberId;  // debtor  = 상대방 (요청 받는 사람)
        private BigDecimal amount;
    }
}
