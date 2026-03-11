package com.tripan.app.controller;

import com.tripan.app.mapper.NotificationMapper;
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
