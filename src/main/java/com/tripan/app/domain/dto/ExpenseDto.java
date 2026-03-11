package com.tripan.app.domain.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import lombok.Getter;
import lombok.Setter;

public class ExpenseDto {

    // 가계부 지출 등록
    @Getter @Setter
    public static class ExpenseCreate {
    	private Long tripId;           // 여행 ID 
        private Long payerId;		   // 결제자 ID
        private String category;       // 카테고리 (TOURISM, FOOD 등)
        private BigDecimal amount;     // 총 결제 금액
        private String description;    // 지출 내용
        private LocalDate expenseDate; // 결제일
        private String paymentType;    // 결제 수단 (카드, 현금 등)
        private String memo;           // 메모
        private String isPrivate;      // 나만보기 여부 (Y/N)
        private String receiptUrl;     // 영수증 이미지 경로
        private List<Long> participantMemberIds; // 분담할 멤버 리스트
    }
    
    // 최종 정산 계산 결과 (누가 누구에게 송금할지)
    @Getter @Setter
    public static class SettlementResult {
        private Long fromMemberId;  // 송금할 사람
        private Long toMemberId;    // 받을 사람
        private BigDecimal amount;  // 금액
    }

    // 지출 분담 내역
    @Getter @Setter
    public static class ExpenseParticipant {
        private Long participantId;  // 분담 기록 ID
        private Long expenseId;      // 지출 ID
        private Long memberId;       // 멤버 ID
        private BigDecimal shareAmount; // 1/N 분담 금액
        private Integer isSettled;   // 정산 완료 여부 (0/1)
    }

    // 최종 정산 영수증
    @Getter @Setter
    public static class Settlement {
        private Long settlementId;   // 영수증 ID
        private Long tripId;         // 여행 ID
        private BigDecimal amount;   // 최종 정산 금액
        private String status;       // 상태
        private LocalDateTime settledAt; // 정산 완료 일시
        private LocalDateTime createdAt; // 영수증 생성 일시
    }
}