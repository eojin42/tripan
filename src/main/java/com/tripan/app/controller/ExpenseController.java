package com.tripan.app.controller;

import com.tripan.app.domain.dto.ExpenseDto;
import com.tripan.app.service.ExpenseService;
import com.tripan.app.websocket.WorkspaceEventPublisher;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/trip/{tripId}")
@RequiredArgsConstructor
public class ExpenseController {

    private final ExpenseService          expenseService;
    private final WorkspaceEventPublisher wsPublisher;

    @GetMapping("/expense")
    public ResponseEntity<Object> getExpenses(@PathVariable("tripId") Long tripId) {
        try { return ResponseEntity.ok(expenseService.getExpenseList(tripId)); }
        catch (Exception e) { return ResponseEntity.ok(List.of()); }
    }

    @PostMapping("/expense")
    public ResponseEntity<Map<String, Object>> addExpense(
            @PathVariable("tripId") Long tripId,
            @RequestBody ExpenseDto.ExpenseCreate dto) {
        dto.setTripId(tripId);
        Long expenseId = expenseService.addExpense(dto);
        wsPublisher.publish(tripId, "EXPENSE_ADDED", expenseId,
                "멤버",
                WorkspaceEventPublisher.payload(
                    "amount", dto.getAmount(),
                    "description", dto.getDescription()));
        return ResponseEntity.ok(Map.of("success", true, "expenseId", expenseId));
    }

    @PatchMapping("/expense/settle")
    public ResponseEntity<Map<String, Object>> settleIndividual(
            @PathVariable("tripId") Long tripId,
            @RequestBody Map<String, Long> body) {
        expenseService.settleIndividual(body.get("participantId"));
        return ResponseEntity.ok(Map.of("success", true));
    }

    @PostMapping("/settlement/calculate")
    public ResponseEntity<List<ExpenseDto.SettlementResult>> calculateSettlement(
            @PathVariable("tripId") Long tripId) {
        return ResponseEntity.ok(expenseService.calculateSettlement(tripId));
    }

    @PatchMapping("/settlement/{settlementId}/complete")
    public ResponseEntity<Map<String, Object>> complete(
            @PathVariable("tripId") Long tripId,
            @PathVariable("settlementId") Long settlementId) {
        expenseService.completeSettlement(settlementId);
        return ResponseEntity.ok(Map.of("success", true));
    }

    @DeleteMapping("/expense/{expenseId}")
    public ResponseEntity<Map<String, Object>> deleteExpense(
            @PathVariable("tripId") Long tripId,
            @PathVariable("expenseId") Long expenseId) {
        try {
            expenseService.deleteExpense(expenseId);
            wsPublisher.publish(tripId, "EXPENSE_DELETED", expenseId, "멤버");
            return ResponseEntity.ok(Map.of("success", true));
        } catch (IllegalStateException e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }
}
