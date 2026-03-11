package com.tripan.app.controller;

import com.tripan.app.domain.dto.ExpenseDto; 
import com.tripan.app.service.ExpenseService; 
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/trip/{tripId}")
@RequiredArgsConstructor
public class ExpenseController {

    private final ExpenseService expenseService;

    // 지출 목록 조회 (workspace 가계부 패널)
    @GetMapping("/expense")
    public ResponseEntity<Object> getExpenses(
            @PathVariable("tripId") Long tripId) {
        try {
            return ResponseEntity.ok(expenseService.getExpenseList(tripId));
        } catch (Exception e) {
            return ResponseEntity.ok(java.util.List.of());
        }
    }

    // 지출 등록
    @PostMapping("/expense")
    public ResponseEntity<Map<String, Object>> addExpense(
            @PathVariable("tripId") Long tripId,
            @RequestBody ExpenseDto.ExpenseCreate dto) {
        dto.setTripId(tripId);
        Long expenseId = expenseService.addExpense(dto);
        return ResponseEntity.ok(Map.of("success", true, "expenseId", expenseId));
    }

    // 개별 건별 정산 완료
    @PatchMapping("/expense/settle")
    public ResponseEntity<Map<String, Object>> settleIndividual(
            @PathVariable("tripId") Long tripId,
            @RequestBody Map<String, Long> body) {
        expenseService.settleIndividual(body.get("participantId"));
        return ResponseEntity.ok(Map.of("success", true));
    }

    // 최종 정산 계산
    @PostMapping("/settlement/calculate")
    public ResponseEntity<List<ExpenseDto.SettlementResult>> calculateSettlement(
            @PathVariable("tripId") Long tripId) {
        return ResponseEntity.ok(expenseService.calculateSettlement(tripId));
    }

    // 송금 완료 처리
    @PatchMapping("/settlement/{settlementId}/complete")
    public ResponseEntity<Map<String, Object>> complete(
            @PathVariable("tripId") Long tripId,
            @PathVariable("settlementId") Long settlementId) {
        expenseService.completeSettlement(settlementId);
        return ResponseEntity.ok(Map.of("success", true));
    }

    // 지출 삭제 (정산 완료 건 불가)
    @DeleteMapping("/expense/{expenseId}")
    public ResponseEntity<Map<String, Object>> deleteExpense(
            @PathVariable("tripId") Long tripId,
            @PathVariable("expenseId") Long expenseId) {
        try {
            expenseService.deleteExpense(expenseId);
            return ResponseEntity.ok(Map.of("success", true));
        } catch (IllegalStateException e) {
            return ResponseEntity.badRequest()
                .body(Map.of("success", false, "message", e.getMessage()));
        }
    }
}