package com.tripan.app.controller;

import com.tripan.app.domain.dto.TripChatDto;
import com.tripan.app.service.TripChatService;
import com.tripan.app.service.TripService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpSession;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/trips/{tripId}/chat")
@RequiredArgsConstructor
public class TripChatController {

    private final TripChatService chatService;
    private final TripService     tripService;
    private final SimpMessagingTemplate messaging;

    /**
     * 채팅방 조회 또는 생성
     * GET /api/trips/{tripId}/chat/room
     */
    @GetMapping("/room")
    public ResponseEntity<Map<String, Object>> getOrCreateRoom(
            @PathVariable("tripId") Long tripId,
            HttpSession session) {

        Long myId = getLoginMemberId(session);
        if (myId == null) return ResponseEntity.status(401).build();

        try {
            String tripName  = tripService.getTripDetails(tripId).getTripName();
            Long chatRoomId  = chatService.getOrCreateChatRoom(tripId, tripName, myId);
            int  unread      = chatService.countUnread(chatRoomId, myId);
            // unread가 있을 때만 lastReadMessageId를 내려줌 (없으면 null → 구분선 불필요)
            Long lastReadId  = (unread > 0) ? chatService.getLastReadMessageId(chatRoomId, myId) : null;

            Map<String, Object> resp = new HashMap<>();
            resp.put("chatRoomId",        chatRoomId);
            resp.put("unreadCount",       unread);
            resp.put("lastReadMessageId", lastReadId);
            return ResponseEntity.ok(resp);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError()
                    .body(Map.of("error", e.getMessage()));
        }
    }

    /**
     * 메시지 목록 조회 (무한 스크롤)
     * GET /api/trips/{tripId}/chat/messages?limit=50&beforeId=xxx
     */
    @GetMapping("/messages")
    public ResponseEntity<List<TripChatDto.MessageResponse>> getMessages(
            @PathVariable("tripId") Long tripId,
            @RequestParam(value = "limit",    defaultValue = "50") int  limit,
            @RequestParam(value = "beforeId", required = false)    Long beforeId,
            HttpSession session) {

        Long myId = getLoginMemberId(session);
        if (myId == null) return ResponseEntity.status(401).build();

        try {
            Long chatRoomId = chatService.getOrCreateChatRoom(tripId, null, myId);
            List<TripChatDto.MessageResponse> messages =
                    chatService.getMessages(chatRoomId, Math.min(limit, 100), beforeId);

            // mine 여부 표시
            messages.forEach(m -> m.setMine(myId.equals(m.getMemberId())));

            return ResponseEntity.ok(messages);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 메시지 전송
     * POST /api/trips/{tripId}/chat/messages
     */
    @PostMapping("/messages")
    public ResponseEntity<Map<String, Object>> sendMessage(
            @PathVariable("tripId") Long tripId,
            @RequestBody TripChatDto.SendRequest req,
            HttpSession session) {

        Long myId = getLoginMemberId(session);
        if (myId == null) return ResponseEntity.status(401).build();

        try {
            Long chatRoomId = chatService.getOrCreateChatRoom(tripId, null, myId);
            TripChatDto.MessageResponse saved = chatService.sendMessage(
                    chatRoomId, myId,
                    req.getContent(),
                    req.getMessageType() != null ? req.getMessageType() : "TALK");

            saved.setMine(true);

            // WebSocket broadcast → 같은 방 구독자에게 전송
            TripChatDto.WsMessage ws = TripChatDto.WsMessage.builder()
                    .type("NEW_MESSAGE")
                    .chatRoomId(chatRoomId)
                    .message(saved)
                    .build();
            messaging.convertAndSend("/sub/trip/" + tripId + "/chat", ws);

            return ResponseEntity.ok(Map.of("success", true, "message", saved));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest()
                    .body(Map.of("success", false, "error", e.getMessage()));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError()
                    .body(Map.of("success", false, "error", "서버 오류"));
        }
    }

    /**
     * 읽음 처리 (채팅창 열릴 때 / 포커스 시 호출)
     * PATCH /api/trips/{tripId}/chat/read
     */
    @PatchMapping("/read")
    public ResponseEntity<Void> markRead(
            @PathVariable("tripId") Long tripId,
            HttpSession session) {

        Long myId = getLoginMemberId(session);
        if (myId == null) return ResponseEntity.status(401).build();

        try {
            Long chatRoomId = chatService.getOrCreateChatRoom(tripId, null, myId);
            chatService.markRead(chatRoomId, myId);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 안 읽은 메시지 수
     * GET /api/trips/{tripId}/chat/unread
     */
    @GetMapping("/unread")
    public ResponseEntity<Map<String, Object>> getUnread(
            @PathVariable("tripId") Long tripId,
            HttpSession session) {

        Long myId = getLoginMemberId(session);
        if (myId == null) return ResponseEntity.status(401).build();

        try {
            Long chatRoomId = chatService.getOrCreateChatRoom(tripId, null, myId);
            int count = chatService.countUnread(chatRoomId, myId);
            return ResponseEntity.ok(Map.of("unreadCount", count));
        } catch (Exception e) {
            return ResponseEntity.ok(Map.of("unreadCount", 0));
        }
    }

    // ── helper ───────────────────────────────────────────────
    private Long getLoginMemberId(HttpSession session) {
        Object user = session.getAttribute("loginUser");
        if (user == null) return null;
        try { return (Long) user.getClass().getMethod("getMemberId").invoke(user); }
        catch (Exception e) { return null; }
    }
}