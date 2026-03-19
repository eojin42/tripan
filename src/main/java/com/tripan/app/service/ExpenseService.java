package com.tripan.app.service;

import java.util.List;

import com.tripan.app.domain.dto.ExpenseDto;
import com.tripan.app.domain.dto.SettlementDto;

public interface ExpenseService {

    // ── 지출 CRUD ──────────────────────────────────────────
    ExpenseDto.DetailResponse createExpense(ExpenseDto.CreateRequest req);
    ExpenseDto.DetailResponse updateExpense(Long expenseId, ExpenseDto.UpdateRequest req);
    void deleteExpense(Long expenseId);

    // ── 지출 조회 ──────────────────────────────────────────
    ExpenseDto.DetailResponse getExpenseDetail(Long expenseId);
    List<ExpenseDto.SummaryResponse> getExpenseList(Long tripId, int page, int size);
    ExpenseDto.TripSummaryResponse getTripExpenseSummary(Long tripId);

    // ── 정산 ───────────────────────────────────────────────
    SettlementDto.PreviewResponse previewSettlement(Long tripId);
    SettlementDto.TripSettlementResponse createSettlements(SettlementDto.CreateBatchRequest req, Long requestMemberId);
    void completeSettlements(SettlementDto.CompleteRequest req);
    void deleteSettlement(Long settlementId);
    SettlementDto.TripSettlementResponse getTripSettlements(Long tripId, Long memberId);
}
