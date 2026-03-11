package com.tripan.app.service;

import com.tripan.app.domain.dto.ExpenseDto;
import java.util.List;
import java.util.Map;

public interface ExpenseService {

    /** 지출 목록 조회 (카테고리별 표시용) */
    List<Map<String, Object>> getExpenseList(Long tripId);

    /** 지출 등록 */
    Long addExpense(ExpenseDto.ExpenseCreate dto);

    /** 개별 정산 완료 */
    void settleIndividual(Long participantId);

    /** 최종 정산 계산 */
    List<ExpenseDto.SettlementResult> calculateSettlement(Long tripId);

    /** 송금 완료 처리 */
    void completeSettlement(Long settlementId);

    /** 지출 삭제 */
    void deleteExpense(Long expenseId);
}
