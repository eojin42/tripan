package com.tripan.app.controller;

import com.tripan.app.service.ItineraryService;
import com.tripan.app.security.CustomUserDetails; 
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/api/itinerary")
@RequiredArgsConstructor
public class ItineraryController {

    private final ItineraryService itineraryService;

    @PatchMapping("/{itemId}/memo")
    public ResponseEntity<Map<String, Object>> saveMemo(
            @PathVariable("itemId") Long itemId,
            @RequestBody Map<String, Object> body,
            @AuthenticationPrincipal CustomUserDetails userDetails
    ) {
        try {
            if (userDetails == null) {
                return ResponseEntity.status(401)
                        .body(Map.of("success", false, "message", "로그인이 필요한 서비스입니다."));
            }

            String memo = (String) body.get("memo");
            String imageBase64 = (String) body.get("imageBase64");
            
            Long loginMemberId = userDetails.getMember().getMemberId();

            String imageUrl = itineraryService.saveMemoAndImage(itemId, memo, imageBase64, loginMemberId);
            
            return ResponseEntity.ok(Map.of("success", true, "imageUrl", imageUrl != null ? imageUrl : ""));
            
        } catch (Exception e) {
            log.error("[ItineraryController] 메모/이미지 저장 중 오류 발생: {}", e.getMessage());
            return ResponseEntity.internalServerError()
                    .body(Map.of("success", false, "message", e.getMessage()));
        }
    }
}