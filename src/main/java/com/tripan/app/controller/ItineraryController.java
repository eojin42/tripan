package com.tripan.app.controller;

import com.tripan.app.domain.dto.TripDto;
import com.tripan.app.service.ItineraryService;
import com.tripan.app.security.CustomUserDetails;
import com.tripan.app.trip.domain.entity.TripDay;
import com.tripan.app.trip.repository.TripDayRepository;
import com.tripan.app.websocket.WorkspaceEventPublisher;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/api/itinerary")
@RequiredArgsConstructor
public class ItineraryController {

    private final ItineraryService        itineraryService;
    private final WorkspaceEventPublisher wsPublisher;
    private final TripDayRepository       dayRepository;

    // ── 장소 추가 + broadcast ─────────────────────────────
    @PostMapping("/trip/{tripId}/day/{dayNumber}/place")
    public ResponseEntity<Map<String, Object>> addPlace(
            @PathVariable("tripId") Long tripId,
            @PathVariable("dayNumber") int dayNumber,
            @RequestBody TripDto.PlaceAddDto dto,
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        if (userDetails == null)
            return ResponseEntity.status(401)
                .body(Map.of("success", false, "message", "로그인이 필요합니다."));
        try {
            TripDay day = dayRepository.findByTripIdAndDayNumber(tripId, dayNumber)
                .orElseThrow(() -> new IllegalArgumentException(
                    "DAY " + dayNumber + " 정보를 찾을 수 없어요 (tripId=" + tripId + ")"));

            Long memberId = userDetails.getMember().getMemberId();
            Long itemId   = itineraryService.addPlaceAndItinerary(tripId, day.getDayId(), dto, memberId);

            wsPublisher.publish(tripId, "PLACE_ADDED", itemId,
                    userDetails.getMember().getNickname(),
                    WorkspaceEventPublisher.payload(
                        "dayNumber", dayNumber,
                        "dayId",     day.getDayId(),
                        "placeName", dto.getPlaceName(),
                        "address",   dto.getAddress()      != null ? dto.getAddress()      : "",
                        "latitude",  dto.getLatitude(),
                        "longitude", dto.getLongitude(),
                        "categoryName",  dto.getCategoryName() != null ? dto.getCategoryName() : "ETC"));

            return ResponseEntity.ok(Map.of("success", true, "itemId", itemId));
        } catch (Exception e) {
            log.error("[Itinerary] 장소 추가 오류: {}", e.getMessage());
            return ResponseEntity.internalServerError()
                    .body(Map.of("success", false, "message", e.getMessage()));
        }
    }

    // ── ★ 메모/이미지 저장 + broadcast ───────────────────
    // 요청 body: { memo, imageBase64List, keepImageUrls }
    @PatchMapping("/{itemId}/memo")
    public ResponseEntity<Map<String, Object>> saveMemo(
            @PathVariable("itemId") Long itemId,
            @RequestBody Map<String, Object> body,
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        if (userDetails == null)
            return ResponseEntity.status(401)
                .body(Map.of("success", false, "message", "로그인이 필요합니다."));
        try {
            String       memo     = (String) body.get("memo");
            Long         memberId = userDetails.getMember().getMemberId();

            // 새 업로드 이미지 (base64)
            @SuppressWarnings("unchecked")
            List<String> b64List = (List<String>) body.get("imageBase64List");
            if (b64List == null) {
                String single = (String) body.get("imageBase64");
                b64List = (single != null && !single.isBlank()) ? List.of(single) : List.of();
            }

            // ✅ 유지할 기존 이미지 URL 목록 (없으면 전체 삭제 — 기존 동작 유지)
            @SuppressWarnings("unchecked")
            List<String> keepImageUrls = (List<String>) body.get("keepImageUrls");

            List<String> imageUrls = itineraryService.saveMemoAndImages(
                    itemId, memo, b64List, keepImageUrls, memberId);

            Long tripId = itineraryService.getTripIdByItemId(itemId);
            if (tripId != null) {
                wsPublisher.publish(tripId, "MEMO_UPDATED", itemId,
                        userDetails.getMember().getNickname(),
                        WorkspaceEventPublisher.payload(
                            "memo",      memo != null ? memo : "",
                            "imageUrls", imageUrls,
                            "imageUrl",  imageUrls.isEmpty() ? "" : imageUrls.get(0)));
            }

            return ResponseEntity.ok(Map.of(
                "success",   true,
                "imageUrls", imageUrls,
                "imageUrl",  imageUrls.isEmpty() ? "" : imageUrls.get(0)
            ));
        } catch (Exception e) {
            log.error("[Itinerary] 메모 저장 오류: {}", e.getMessage());
            return ResponseEntity.internalServerError()
                    .body(Map.of("success", false, "message", e.getMessage()));
        }
    }

    // ── 드래그앤드롭 순서/DAY 이동 + broadcast ───────────
    @PatchMapping("/{itemId}/move")
    public ResponseEntity<Map<String, Object>> moveItem(
            @PathVariable("itemId") Long itemId,
            @RequestBody Map<String, Object> body,
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        if (userDetails == null)
            return ResponseEntity.status(401)
                .body(Map.of("success", false, "message", "로그인이 필요합니다."));
        try {
            int    dayNumber  = Integer.parseInt(body.get("dayNumber").toString());
            String visitOrder = body.get("visitOrder").toString();
            itineraryService.moveItem(itemId, dayNumber, visitOrder);

            Long tripId = itineraryService.getTripIdByItemId(itemId);
            if (tripId != null) {
                wsPublisher.publish(tripId, "ORDER_UPDATED", itemId,
                        userDetails.getMember().getNickname(),
                        WorkspaceEventPublisher.payload(
                            "dayNumber",  dayNumber,
                            "visitOrder", visitOrder));
            }
            return ResponseEntity.ok(Map.of("success", true));
        } catch (Exception e) {
            log.error("[Itinerary] move 오류: {}", e.getMessage());
            return ResponseEntity.internalServerError()
                    .body(Map.of("success", false, "message", e.getMessage()));
        }
    }

    // ── 장소 삭제 + broadcast ─────────────────────────────
    @DeleteMapping("/{itemId}")
    public ResponseEntity<Map<String, Object>> deleteItem(
            @PathVariable("itemId") Long itemId,
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        if (userDetails == null)
            return ResponseEntity.status(401)
                .body(Map.of("success", false, "message", "로그인이 필요합니다."));
        try {
            Long tripId = itineraryService.getTripIdByItemId(itemId);
            itineraryService.deleteItem(itemId);
            if (tripId != null)
                wsPublisher.publish(tripId, "PLACE_DELETED", itemId,
                        userDetails.getMember().getNickname());
            return ResponseEntity.ok(Map.of("success", true));
        } catch (Exception e) {
            return ResponseEntity.internalServerError()
                    .body(Map.of("success", false, "message", e.getMessage()));
        }
    }
}
