package com.tripan.app.controller;

import java.util.Map;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import com.tripan.app.security.CustomUserDetails;
import com.tripan.app.service.TripMemberService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@RestController
@RequestMapping("/api/trip/{tripId}/members")
@RequiredArgsConstructor
public class TripMemberRestController {

    private final TripMemberService tripMemberService;

    // 권한 변경 (PATCH)
    @PatchMapping("/{targetMemberId}/role")
    public ResponseEntity<?> changeRole(
            @PathVariable("tripId") Long tripId,
            @PathVariable("targetMemberId") Long targetMemberId,
            @RequestBody Map<String, String> body,
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        try {
            tripMemberService.updateMemberRole(tripId, targetMemberId, body.get("role"), userDetails.getMember().getMemberId());
            return ResponseEntity.ok(Map.of("success", true, "message", "권한이 변경되었습니다."));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }

    // 강퇴 (DELETE)
    // ★ body에 targetNickname 을 함께 받아서 서비스로 전달
    //   JS(workspace_ui.js): fetch body에 { targetNickname: MEMBER_DICT[memberId] } 추가 필요
    @DeleteMapping("/{targetMemberId}/kick")
    public ResponseEntity<?> kickMember(
            @PathVariable("tripId") Long tripId,
            @PathVariable("targetMemberId") Long targetMemberId,
            @RequestBody(required = false) Map<String, String> body,
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        try {
            String targetNickname = (body != null) ? body.getOrDefault("targetNickname", "") : "";
            tripMemberService.kickMember(tripId, targetMemberId, userDetails.getMember().getMemberId(), targetNickname);
            return ResponseEntity.ok(Map.of("success", true, "message", "멤버를 내보냈습니다."));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }

    // 스스로 나가기 (DELETE)
    // ★ CustomUserDetails에서 닉네임 추출해서 서비스로 전달
    @DeleteMapping("/leave")
    public ResponseEntity<?> leaveTrip(
            @PathVariable("tripId") Long tripId,
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        try {
            // CustomUserDetails → getMember().getNickname() 구조 사용
            String myNick = "";
            try { myNick = userDetails.getMember().getNickname(); } catch (Exception ignored) {}
            tripMemberService.leaveTrip(tripId, userDetails.getMember().getMemberId(), myNick);
            return ResponseEntity.ok(Map.of("success", true, "message", "여행에서 성공적으로 나갔습니다."));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }
}