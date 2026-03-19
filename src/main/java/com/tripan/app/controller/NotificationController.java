package com.tripan.app.controller;

import com.tripan.app.mapper.NotificationMapper;
import com.tripan.app.service.NotificationService;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/notification")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationMapper notificationMapper;
    private final NotificationService notificationService;

    @GetMapping
    public List<Map<String, Object>> getNotifications(
            @RequestParam("tripId") Long tripId,
            HttpSession session) {
        Long memberId = getMemberId(session);
        if (memberId == null) return List.of();
        return notificationMapper.selectByTripIdAndReceiver(tripId, memberId);
    }

    @PatchMapping("/{notificationId}/read")
    public ResponseEntity<Map<String, Object>> markRead(
            @PathVariable("notificationId") Long notificationId) {
        notificationMapper.markAsRead(notificationId);
        return ResponseEntity.ok(Map.of("success", true));
    }

    /**
     * 정산 요청 알림 발송 (JS에서 POST /api/notification/send 호출)
     */
    @PostMapping("/send")
    public ResponseEntity<Map<String, Object>> sendNotification(
            @RequestBody Map<String, Object> body,
            HttpSession session) {
        try {
            Long tripId     = Long.valueOf(String.valueOf(body.get("tripId")));
            Long receiverId = Long.valueOf(String.valueOf(body.get("receiverId")));
            String message  = String.valueOf(body.getOrDefault("message", "정산 요청이 왔어요"));
            String type     = String.valueOf(body.getOrDefault("type", "SETTLEMENT"));
            Long senderId   = getMemberId(session);
            notificationService.notifyOne(tripId, receiverId, senderId, message, type);
            return ResponseEntity.ok(Map.of("success", true));
        } catch (Exception e) {
            return ResponseEntity.ok(Map.of("success", false, "error", e.getMessage()));
        }
    }

    @PatchMapping("/read-all")
    public ResponseEntity<Map<String, Object>> markAllRead(
            @RequestParam("tripId") Long tripId,
            HttpSession session) {
        Long memberId = getMemberId(session);
        if (memberId != null) notificationMapper.markAllAsRead(tripId, memberId);
        return ResponseEntity.ok(Map.of("success", true));
    }

    private Long getMemberId(HttpSession session) {
        try {
            Object user = session.getAttribute("loginUser");
            return user == null ? null : (Long) user.getClass().getMethod("getMemberId").invoke(user);
        } catch (Exception e) { return null; }
    }
}
