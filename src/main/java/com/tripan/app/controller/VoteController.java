package com.tripan.app.controller;

import com.tripan.app.service.VoteService;
import com.tripan.app.service.NotificationService;
import com.tripan.app.websocket.WorkspaceEventPublisher;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.time.format.DateTimeParseException;
import java.util.List;
import java.util.Map;

/**
 * VoteController
 * ─────────────────────────────────────────
 * HttpSession 방식으로 통일 (TripController 와 동일)
 * → @AuthenticationPrincipal 이 null 되는 문제 완전 차단
 */
@RestController
@RequestMapping("/api/trip/{tripId}/vote")
@RequiredArgsConstructor
public class VoteController {

    private final VoteService             voteService;
    private final WorkspaceEventPublisher wsPublisher;
    private final NotificationService     notificationService;

    // ── 투표 목록 조회 ────────────────────────────────────
    @GetMapping
    public List<Map<String, Object>> getVotes(
            @PathVariable("tripId") Long tripId,
            @RequestParam(value = "memberId", required = false) Long memberIdParam,
            HttpSession session) {

        // ★ 세션에서 직접 꺼냄 (Security 의존 제거) → 새로고침 후에도 항상 올바른 ID
        Long memberId = getLoginMemberId(session);
        // 세션이 없으면 쿼리파라미터 폴백 (JSP LOGIN_MEMBER_ID)
        if (memberId == null) memberId = memberIdParam;

        return voteService.getVotes(tripId, memberId);
    }

    // ── 투표 생성 ─────────────────────────────────────────
    @PostMapping
    public ResponseEntity<Map<String, Object>> createVote(
            @PathVariable("tripId") Long tripId,
            @RequestBody Map<String, Object> body,
            HttpSession session) {

        String title = (String) body.get("title");
        @SuppressWarnings("unchecked")
        List<String> candidates = (List<String>) body.get("candidates");

        if (title == null || title.isBlank())
            return ResponseEntity.ok(Map.of("success", false, "message", "투표 제목이 필요합니다"));
        if (candidates == null || candidates.size() < 2)
            return ResponseEntity.ok(Map.of("success", false, "message", "후보지가 2개 이상 필요합니다"));

        // deadline: "2026-03-20T18:00" 형식 or null(무기한)
        LocalDateTime deadline = null;
        String deadlineStr = (String) body.get("deadline");
        if (deadlineStr != null && !deadlineStr.isBlank()) {
            try {
                deadline = LocalDateTime.parse(deadlineStr);
                if (deadline.isBefore(LocalDateTime.now()))
                    return ResponseEntity.ok(Map.of("success", false, "message", "마감일시가 현재보다 이전이에요"));
            } catch (DateTimeParseException e) {
                return ResponseEntity.ok(Map.of("success", false, "message", "마감일시 형식이 올바르지 않아요"));
            }
        }

        Long voteId = voteService.createVote(tripId, title, candidates, deadline);

        String nick = getLoginNickname(session);
        Long myId   = getLoginMemberId(session);
        wsPublisher.publish(tripId, "VOTE_CREATED", voteId, nick != null ? nick : "멤버",
                WorkspaceEventPublisher.payload("title", title));

        // ★ DB 알림 저장
        notificationService.notifyAll(tripId, myId,
            (nick != null ? nick : "누군가") + "님이 투표 [" + title + "] 를 만들었어요 🗳️", "VOTE");

        return ResponseEntity.ok(Map.of("success", true, "voteId", voteId));
    }

    // ── 투표 참여 ─────────────────────────────────────────
    @PostMapping("/{voteId}/cast")
    public ResponseEntity<Map<String, Object>> castVote(
            @PathVariable("tripId") Long tripId,
            @PathVariable("voteId") Long voteId,
            @RequestBody Map<String, Object> body,
            HttpSession session) {

        Long memberId = getLoginMemberId(session);
        if (memberId == null)
            return ResponseEntity.status(401)
                    .body(Map.of("success", false, "message", "로그인이 필요합니다"));

        Long candidateId = ((Number) body.get("candidateId")).longValue();

        try {
            voteService.castVote(voteId, candidateId, memberId);
        } catch (IllegalStateException e) {
            return ResponseEntity.ok(Map.of(
                    "success",     false,
                    "message",     e.getMessage(),
                    "candidateId", candidateId
            ));
        }

        String nick = getLoginNickname(session);
        wsPublisher.publish(tripId, "VOTE_CASTED", voteId, nick != null ? nick : "멤버",
                WorkspaceEventPublisher.payload("candidateId", candidateId));

        return ResponseEntity.ok(Map.of("success", true));
    }

    // ── 투표 삭제 ─────────────────────────────────────────
    @DeleteMapping("/{voteId}")
    public ResponseEntity<Map<String, Object>> deleteVote(
            @PathVariable("tripId") Long tripId,
            @PathVariable("voteId") Long voteId,
            HttpSession session) {

        String nick = getLoginNickname(session);
        Long   myId = getLoginMemberId(session);

        // ★ 삭제 전 투표 제목 조회 (서비스에 메서드 있으면 사용, 없으면 fallback)
        String voteTitle = "투표";
        try {
            String fetched = voteService.getVoteTitle(voteId);
            if (fetched != null && !fetched.isBlank()) voteTitle = fetched;
        } catch (Exception ignored) {}

        voteService.deleteVote(voteId, tripId);

        wsPublisher.publish(tripId, "VOTE_DELETED", voteId, nick != null ? nick : "멤버");

        // ★ DB 알림 저장
        notificationService.notifyAll(tripId, myId,
            (nick != null ? nick : "누군가") + "님이 투표 [" + voteTitle + "] 를 삭제했어요 🗑️", "VOTE");

        return ResponseEntity.ok(Map.of("success", true));
    }

    // ── 세션 유틸 (TripController 와 동일 방식) ──────────
    private Long getLoginMemberId(HttpSession session) {
        Object user = session.getAttribute("loginUser");
        if (user == null) return null;
        try { return (Long) user.getClass().getMethod("getMemberId").invoke(user); }
        catch (Exception e) { return null; }
    }

    private String getLoginNickname(HttpSession session) {
        Object user = session.getAttribute("loginUser");
        if (user == null) return null;
        try { return (String) user.getClass().getMethod("getNickname").invoke(user); }
        catch (Exception e) { return null; }
    }
}
