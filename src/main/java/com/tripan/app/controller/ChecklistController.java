package com.tripan.app.controller;

import com.tripan.app.mapper.ChecklistMapper;
import com.tripan.app.websocket.WorkspaceEventPublisher;
import com.tripan.app.trip.domain.entity.TripChecklist;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/trip/{tripId}/checklist")
@RequiredArgsConstructor
public class ChecklistController {

    private final ChecklistMapper         checklistMapper;
    private final WorkspaceEventPublisher wsPublisher;

    /* ── 전체 조회 ───────────────────────────────────── */
    @GetMapping
    public List<Map<String, Object>> getChecklist(@PathVariable("tripId") Long tripId) {
        return checklistMapper.selectByTripId(tripId);
    }

    /* ── 항목 추가 ────────────────────────────────────── */
    @PostMapping
    public ResponseEntity<Map<String, Object>> addItem(
            @PathVariable("tripId") Long tripId,
            @RequestBody Map<String, String> body) {

        String itemName     = body.get("itemName");
        String category     = body.getOrDefault("category", "기타");
        String checkManager = body.get("checkManager");

        if (itemName == null || itemName.isBlank())
            return ResponseEntity.badRequest()
                    .body(Map.of("success", false, "message", "항목 이름이 필요합니다"));

        TripChecklist item = new TripChecklist();
        item.setTripId(tripId);
        item.setItemName(itemName);
        item.setCategory(category);
        item.setCheckManager(checkManager);
        checklistMapper.insertItem(item);

        wsPublisher.publish(tripId, "CHECKLIST_ADDED", item.getChecklistId(),
                checkManager != null ? checkManager : "멤버",
                WorkspaceEventPublisher.payload(
                        "itemName",    itemName,
                        "category",    category,
                        "checklistId", item.getChecklistId()));

        return ResponseEntity.ok(Map.of("success", true, "checklistId", item.getChecklistId()));
    }

    /* ── 체크박스 토글 ────────────────────────────────── */
    @PatchMapping("/{checklistId}/toggle")
    public ResponseEntity<Map<String, Object>> toggle(
            @PathVariable("tripId") Long tripId,
            @PathVariable("checklistId") Long checklistId) {

        checklistMapper.toggleItem(checklistId);

        /*
         * ✅ getIsDone 쿼리 추가 없이 해결:
         *    broadcast 수신 측(ws.js)에서 loadChecklist() 전체 리로드.
         *    isDone payload는 보내지 않음 → XML 수정 불필요.
         */
        wsPublisher.publish(tripId, "CHECKLIST_TOGGLED", checklistId, "멤버");

        return ResponseEntity.ok(Map.of("success", true));
    }

    /* ── 항목 삭제 ────────────────────────────────────── */
    @DeleteMapping("/{checklistId}")
    public ResponseEntity<Map<String, Object>> deleteItem(
            @PathVariable("tripId") Long tripId,
            @PathVariable("checklistId") Long checklistId) {

        checklistMapper.deleteItem(checklistId, tripId);
        wsPublisher.publish(tripId, "CHECKLIST_DELETED", checklistId, "멤버");
        return ResponseEntity.ok(Map.of("success", true));
    }

    /* ── 카테고리 목록 ────────────────────────────────── */
    @GetMapping("/categories")
    public List<String> getCategories(@PathVariable("tripId") Long tripId) {
        return checklistMapper.selectCategories(tripId);
    }
}
