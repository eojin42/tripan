package com.tripan.app.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestAttribute;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.tripan.app.domain.dto.ExpenseDto;
import com.tripan.app.domain.dto.SettlementDto;
import com.tripan.app.service.ExpenseService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class ExpenseController {

    private final ExpenseService expenseService;

    // ════════════════════════════════════════════════════════
    //  지출 API
    // ════════════════════════════════════════════════════════

    /**
     * 지출 등록
     * POST /api/trips/{tripId}/expenses
     */
    @PostMapping("/trips/{tripId}/expenses")
    public ResponseEntity<ExpenseDto.DetailResponse> createExpense(
            @PathVariable("tripId") Long tripId,           // ← 이름 명시
            @RequestBody ExpenseDto.CreateRequest req) {

        req.setTripId(tripId);
        return ResponseEntity.ok(expenseService.createExpense(req));
    }

    /**
     * 지출 목록 조회 (페이징)
     * GET /api/trips/{tripId}/expenses
     */
    @GetMapping("/trips/{tripId}/expenses")
    public ResponseEntity<List<ExpenseDto.SummaryResponse>> getExpenseList(
            @PathVariable("tripId") Long tripId,
            @RequestParam(value = "page", defaultValue = "1")  int page,   // ← value 명시
            @RequestParam(value = "size", defaultValue = "20") int size) {

        return ResponseEntity.ok(expenseService.getExpenseList(tripId, page, size));
    }

    /**
     * 지출 통계 (카테고리별, 멤버별 결제/부담)
     * GET /api/trips/{tripId}/expenses/summary
     */
    @GetMapping("/trips/{tripId}/expenses/summary")
    public ResponseEntity<ExpenseDto.TripSummaryResponse> getExpenseSummary(
            @PathVariable("tripId") Long tripId) {

        return ResponseEntity.ok(expenseService.getTripExpenseSummary(tripId));
    }

    /**
     * 지출 상세 조회
     * GET /api/expenses/{expenseId}
     */
    @GetMapping("/expenses/{expenseId}")
    public ResponseEntity<ExpenseDto.DetailResponse> getExpenseDetail(
            @PathVariable("expenseId") Long expenseId) {

        return ResponseEntity.ok(expenseService.getExpenseDetail(expenseId));
    }

    /**
     * 지출 수정 (분담자 전체 교체)
     * PUT /api/expenses/{expenseId}
     */
    @PutMapping("/expenses/{expenseId}")
    public ResponseEntity<ExpenseDto.DetailResponse> updateExpense(
            @PathVariable("expenseId") Long expenseId,
            @RequestBody ExpenseDto.UpdateRequest req) {

        return ResponseEntity.ok(expenseService.updateExpense(expenseId, req));
    }

    /**
     * 지출 삭제
     * DELETE /api/expenses/{expenseId}
     * 응답: 204 No Content
     */
    @DeleteMapping("/expenses/{expenseId}")
    public ResponseEntity<Void> deleteExpense(
            @PathVariable("expenseId") Long expenseId) {

        expenseService.deleteExpense(expenseId);
        return ResponseEntity.noContent().build();
    }

    // ════════════════════════════════════════════════════════
    //  정산 API
    // ════════════════════════════════════════════════════════

    /**
     * 정산 미리보기 (DB 저장 없음)
     * GET /api/trips/{tripId}/settlements/preview
     */
    @GetMapping("/trips/{tripId}/settlements/preview")
    public ResponseEntity<SettlementDto.PreviewResponse> previewSettlement(
            @PathVariable("tripId") Long tripId) {

        return ResponseEntity.ok(expenseService.previewSettlement(tripId));
    }

    /**
     * 정산 일괄 생성 (DB 저장)
     * POST /api/trips/{tripId}/settlements
     */
    @PostMapping("/trips/{tripId}/settlements")
    public ResponseEntity<SettlementDto.TripSettlementResponse> createSettlements(
            @PathVariable("tripId") Long tripId,
            @RequestBody SettlementDto.CreateBatchRequest req,
            @RequestAttribute(name = "loginMemberId", required = false) Long loginMemberId,
            @RequestParam(value = "memberId", required = false) Long memberIdParam) {

        req.setTripId(tripId);
        Long memberId = loginMemberId != null ? loginMemberId
                      : memberIdParam   != null ? memberIdParam
                      : 0L;
        return ResponseEntity.ok(expenseService.createSettlements(req, memberId));
    }

    /**
     * 여행 전체 정산 현황 조회
     * GET /api/trips/{tripId}/settlements
     */
    @GetMapping("/trips/{tripId}/settlements")
    public ResponseEntity<SettlementDto.TripSettlementResponse> getSettlements(
            @PathVariable("tripId") Long tripId,
            @RequestAttribute(name = "loginMemberId", required = false) Long loginMemberId,
            @RequestParam(value = "memberId", required = false) Long memberIdParam) {

        Long memberId = loginMemberId != null ? loginMemberId
                      : memberIdParam   != null ? memberIdParam
                      : 0L;
        return ResponseEntity.ok(expenseService.getTripSettlements(tripId, memberId));
    }

    /**
     * 정산 완료 처리 (송금 체크)
     * PATCH /api/settlements/complete
     */
    @PatchMapping("/settlements/complete")
    public ResponseEntity<Void> completeSettlements(
            @RequestBody SettlementDto.CompleteRequest req) {

        expenseService.completeSettlements(req);
        return ResponseEntity.ok().build();
    }

    /**
     * 정산 단건 삭제
     * DELETE /api/settlements/{settlementId}
     */
    @DeleteMapping("/settlements/{settlementId}")
    public ResponseEntity<Void> deleteSettlement(
            @PathVariable("settlementId") Long settlementId) {

        expenseService.deleteSettlement(settlementId);
        return ResponseEntity.noContent().build();
    }
}
