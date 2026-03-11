package com.tripan.app.controller;

import com.tripan.app.mapper.ChecklistMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/trip/{tripId}/checklist")
@RequiredArgsConstructor
public class ChecklistController {

    private final ChecklistMapper checklistMapper;

    @GetMapping
    public List<Map<String, Object>> getChecklist(
            @PathVariable("tripId") Long tripId) {
        return checklistMapper.selectByTripId(tripId);
    }

    @PostMapping
    public ResponseEntity<Map<String, Object>> addItem(
            @PathVariable("tripId") Long tripId,
            @RequestBody Map<String, String> body) {
        String itemName     = body.get("itemName");
        String category     = body.getOrDefault("category", "기타");
        String checkManager = body.get("checkManager");
        
        if (itemName == null || itemName.isBlank())
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", "항목 이름이 필요합니다"));

        com.tripan.app.trip.domain.entity.TripChecklist item = new com.tripan.app.trip.domain.entity.TripChecklist();
        item.setTripId(tripId);
        item.setItemName(itemName);
        item.setCategory(category);
        item.setCheckManager(checkManager);

        checklistMapper.insertItem(item); // 쿼리 실행 시 item 객체 안에 DB에서 생성된 ID가 주입
        
        return ResponseEntity.ok(Map.of("success", true, "checklistId", item.getChecklistId()));
    }

    @PatchMapping("/{checklistId}/toggle")
    public ResponseEntity<Map<String, Object>> toggle(
            @PathVariable("tripId") Long tripId,
            @PathVariable("checklistId") Long checklistId) {
        checklistMapper.toggleItem(checklistId);
        return ResponseEntity.ok(Map.of("success", true));
    }

    @DeleteMapping("/{checklistId}")
    public ResponseEntity<Map<String, Object>> deleteItem(
            @PathVariable("tripId") Long tripId,
            @PathVariable("checklistId") Long checklistId) {
        checklistMapper.deleteItem(checklistId, tripId);
        return ResponseEntity.ok(Map.of("success", true));
    }

    @GetMapping("/categories")
    public List<String> getCategories(
            @PathVariable("tripId") Long tripId) {
        return checklistMapper.selectCategories(tripId);
    }
}
