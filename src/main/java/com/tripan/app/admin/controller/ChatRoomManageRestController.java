package com.tripan.app.admin.controller;


import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.tripan.app.admin.domain.dto.ChatMemberManageDto;
import com.tripan.app.admin.domain.dto.ChatMessageManageDto;
import com.tripan.app.admin.domain.dto.ChatRoomManageDto;
import com.tripan.app.admin.service.ChatRoomManageService;

import java.util.List;
import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/admin/api/chat/rooms")
@RequiredArgsConstructor
public class ChatRoomManageRestController {

    private final ChatRoomManageService chatRoomAdminService;

    /* GET  /admin/api/chat/rooms */
    @GetMapping
    public ResponseEntity<List<ChatRoomManageDto>> getRooms() {
        return ResponseEntity.ok(chatRoomAdminService.getAllRooms());
    }

    /* GET  /admin/api/chat/rooms/stats */
    @GetMapping("/stats")
    public ResponseEntity<ChatRoomManageDto.StatsResponse> getStats() {
        return ResponseEntity.ok(chatRoomAdminService.getStats());
    }

    /* GET  /admin/api/chat/rooms/{chatRoomId} */
    @GetMapping("/{chatRoomId}")
    public ResponseEntity<ChatRoomManageDto> getRoom(@PathVariable("chatRoomId") Long chatRoomId) {
        return ResponseEntity.ok(chatRoomAdminService.getRoomById(chatRoomId));
    }

    /* POST /admin/api/chat/rooms */
    @PostMapping
    public ResponseEntity<ChatRoomManageDto> createRoom(
            @RequestBody ChatRoomManageDto.CreateRequest request) {
        return ResponseEntity.ok(chatRoomAdminService.createRoom(request));
    }

    @PatchMapping("/{chatRoomId}/status")
    public ResponseEntity<Void> updateStatus(
            @PathVariable("chatRoomId") Long chatRoomId,
            @RequestBody  ChatRoomManageDto.StatusRequest request) {
        chatRoomAdminService.updateStatus(chatRoomId, request.getStatus());
        return ResponseEntity.ok().build();
    }

    /* DELETE /admin/api/chat/rooms/{chatRoomId} */
    @DeleteMapping("/{chatRoomId}")
    public ResponseEntity<Void> deleteRoom(@PathVariable("chatRoomId") Long chatRoomId) {
        chatRoomAdminService.deleteRoom(chatRoomId);
        return ResponseEntity.ok().build();
    }

    /* GET  /admin/api/chat/rooms/{chatRoomId}/members */
    @GetMapping("/{chatRoomId}/members")
    public ResponseEntity<List<ChatMemberManageDto>> getMembers(@PathVariable("chatRoomId") Long chatRoomId) {
        return ResponseEntity.ok(chatRoomAdminService.getMembers(chatRoomId));
    }

    /* POST /admin/api/chat/rooms/{chatRoomId}/members/{memberId}/kick */
    @PostMapping("/{chatRoomId}/members/{memberId}/kick")
    public ResponseEntity<Void> kickMember(
            @PathVariable("chatRoomId") Long chatRoomId,
            @PathVariable("memberId") Long memberId) {
        chatRoomAdminService.kickMember(chatRoomId, memberId);
        return ResponseEntity.ok().build();
    }

    /* POST /admin/api/chat/rooms/{chatRoomId}/members/{memberId}/block */
    @PostMapping("/{chatRoomId}/members/{memberId}/block")
    public ResponseEntity<Void> blockMember(
            @PathVariable("chatRoomId") Long chatRoomId,
            @PathVariable("memberId") Long memberId) {
        chatRoomAdminService.blockMember(chatRoomId, memberId);
        return ResponseEntity.ok().build();
    }

    /* GET  /admin/api/chat/rooms/{chatRoomId}/messages?size=30 */
    @GetMapping("/{chatRoomId}/messages")
    public ResponseEntity<List<ChatMessageManageDto>> getMessages(
            @PathVariable("chatRoomId") Long chatRoomId,
            @RequestParam(value="size", defaultValue = "100") int size,
            @RequestParam(name = "searchDate", required = false) String searchDate) {
        return ResponseEntity.ok(chatRoomAdminService.getMessages(chatRoomId, size, searchDate));
    }

    /* 예외 처리 */
    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<Map<String, String>> handleIllegalArg(IllegalArgumentException e) {
        log.warn("[ChatRoomAdmin] 잘못된 요청: {}", e.getMessage());
        return ResponseEntity.badRequest().body(Map.of("message", e.getMessage()));
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<Map<String, String>> handleException(Exception e) {
        log.error("[ChatRoomAdmin] 서버 오류", e);
        return ResponseEntity.internalServerError().body(Map.of("message", "서버 오류가 발생했습니다."));
    }
}