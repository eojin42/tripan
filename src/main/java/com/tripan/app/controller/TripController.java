package com.tripan.app.controller;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.tripan.app.domain.dto.TripCreateDto;
import com.tripan.app.domain.dto.TripDto;
import com.tripan.app.service.NotificationService;
import com.tripan.app.service.TripService;
import com.tripan.app.trip.repository.TripMemberRepository;
import com.tripan.app.websocket.WorkspaceEventPublisher;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/trip")
@RequiredArgsConstructor
public class TripController {

    private final TripService tripService;
    private final WorkspaceEventPublisher wsPublisher;
    private final NotificationService notificationService;
    private final TripMemberRepository tripMemberRepository;
    
    @Value("${tripan.api.kakao-map-api-key}")
    private String kakaoMapKey; // yml에서 읽어옴 

    @GetMapping("/trip_create")
    public String create(Model model) {
        return "trip/trip_create";
    }

    @GetMapping("/{tripId}/workspace")
    public String workspace(
            @PathVariable("tripId") Long tripId,
            HttpSession session, Model model) {

        if (getLoginMemberId(session) == null) return "redirect:/member/login";

        TripDto tripDto = tripService.getTripDetails(tripId);
        long nights = ChronoUnit.DAYS.between(
                LocalDate.parse(tripDto.getStartDate().substring(0, 10)),
                LocalDate.parse(tripDto.getEndDate().substring(0, 10)));
        String tripNights = nights == 0 ? "당일치기" : (nights + "박 " + (nights + 1) + "일");

        model.addAttribute("tripId",       tripId);
        model.addAttribute("tripDto",      tripDto);
        model.addAttribute("tripNights",   tripNights);
        model.addAttribute("kakaoMapKey",  kakaoMapKey);

        String nick = getLoginNickname(session);
        model.addAttribute("loginNickname", nick != null ? nick : "");

        // ★ 환영 모달: 현재 유저의 isFirstVisit 확인
        Long loginMemberIdForWelcome = getLoginMemberId(session);
        boolean showWelcome = false;
        if (loginMemberIdForWelcome != null) {
            showWelcome = tripMemberRepository
                .findByTripIdAndMemberId(tripId, loginMemberIdForWelcome)
                .map(m -> Integer.valueOf(1).equals(m.getIsFirstVisit()))
                .orElse(false);
        }
        model.addAttribute("showWelcome",  showWelcome);
        // OWNER(생성자) 여부 판별
        boolean isOwner = tripMemberRepository
            .findByTripIdAndMemberId(tripId, loginMemberIdForWelcome)
            .map(m -> "OWNER".equals(m.getRole()))
            .orElse(false);
        model.addAttribute("isOwner", isOwner);

        return "trip/workspace";
    }

    @PostMapping("/create")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> createTrip(
            @RequestBody TripCreateDto dto, HttpSession session) {
        Long loginMemberId = getLoginMemberId(session);
        if (loginMemberId == null)
            return ResponseEntity.status(401).body(Map.of("success", false, "message", "로그인이 필요합니다"));
        try {
            Long tripId = tripService.createTrip(dto, loginMemberId);
            return ResponseEntity.ok(Map.of("success", true, "tripId", tripId));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body(Map.of("success", false, "message", e.getMessage()));
        }
    }

    @PatchMapping("/{tripId}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> updateTrip(
    		@PathVariable("tripId") Long tripId, @RequestBody TripCreateDto dto, HttpSession session) {
        if (getLoginMemberId(session) == null)
            return ResponseEntity.status(401).body(Map.of("success", false));
        try {
            tripService.updateTrip(tripId, dto);
            String nick = getLoginNickname(session);
            wsPublisher.publish(tripId, "TRIP_UPDATED", tripId,
                    nick != null ? nick : "멤버",
                    WorkspaceEventPublisher.payload(
                        "tripName",  dto.getTitle(),
                        "startDate", dto.getStartDate(),
                        "endDate",   dto.getEndDate()
                    ));
            return ResponseEntity.ok(Map.of("success", true));
        } catch (Exception e) {
            return ResponseEntity.status(500).body(Map.of("success", false, "message", e.getMessage()));
        }
    }

    @DeleteMapping("/{tripId}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> deleteTrip(
    		@PathVariable("tripId") Long tripId, HttpSession session) {
        if (getLoginMemberId(session) == null)
            return ResponseEntity.status(401).body(Map.of("success", false));
        tripService.deleteTrip(tripId);
        return ResponseEntity.ok(Map.of("success", true));
    }
    
    @GetMapping("/invite/{inviteCode}")
    public String acceptInviteLink(@PathVariable("inviteCode") String inviteCode, HttpSession session) {
        Long loginMemberId = getLoginMemberId(session);
        if (loginMemberId == null) {
            session.setAttribute("redirectAfterLogin", "/trip/invite/" + inviteCode);
            return "redirect:/member/login";
        }
        try {
            Long tripId = tripService.joinTripViaLink(inviteCode, loginMemberId);
            String nick = getLoginNickname(session);
            
            // 진짜 처음 들어온 사람일 때만 웹소켓과 알림
            wsPublisher.publish(tripId, "MEMBER_JOINED", loginMemberId,
                    nick != null ? nick : "새 멤버",
                    WorkspaceEventPublisher.payload("nickname", nick != null ? nick : "새 멤버"));
            
            notificationService.notifyAll(tripId, loginMemberId, nick + "님이 여행에 합류했어요 🎉", "ACCEPT");
            notificationService.notifyOne(tripId, loginMemberId, loginMemberId, "여행 워크스페이스에 합류하셨네요! 환영합니다 ✈️", "SYSTEM");
            
            return "redirect:/trip/" + tripId + "/workspace";

        } catch (IllegalStateException e) {
            // 방어 로직) 이미 합류한 멤버(방장 포함)가 또 눌렀을 때
            String msg = e.getMessage();
            if (msg != null && msg.startsWith("ALREADY_JOINED:")) {
                String existingTripId = msg.split(":")[1];
                // 알림 쏘는 로직을 다 무시하고, 조용히 기존 워크스페이스로만 넘겨버림
                return "redirect:/trip/" + existingTripId + "/workspace"; 
            }
            e.printStackTrace();
            return "redirect:/?error=already_joined";
            
        } catch (Exception e) {
            e.printStackTrace(); 
            return "redirect:/?error=invalid_invite";
        }
    }

    @PostMapping("/{tripId}/invite/search")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> inviteBySearch(
    		@PathVariable("tripId") Long tripId, @RequestBody Map<String, Long> body, HttpSession session) {
        if (getLoginMemberId(session) == null)
            return ResponseEntity.status(401).body(Map.of("success", false));
        try {
            tripService.inviteMemberToTrip(tripId, body.get("targetMemberId"));
            return ResponseEntity.ok(Map.of("success", true));
        } catch (IllegalStateException e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }

    @PatchMapping("/{tripId}/member/{memberId}/accept")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> acceptInvite(
    		@PathVariable("tripId") Long tripId, @PathVariable Long memberId) {
        tripService.acceptTripInvitation(tripId, memberId);
        return ResponseEntity.ok(Map.of("success", true));
    }

    //  초대 거절 (PENDING → 레코드 삭제)
    @DeleteMapping("/{tripId}/member/{memberId}/decline")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> declineInvite(
    		@PathVariable("tripId") Long tripId, @PathVariable Long memberId) {
        try {
            tripService.leaveTrip(tripId, memberId); // 내부적으로 trip_member 레코드 삭제
            return ResponseEntity.ok(Map.of("success", true));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }

    // 동행자 강퇴 (방장 전용)
    @DeleteMapping("/{tripId}/member/{memberId}/kick")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> kickMember(
    		@PathVariable("tripId") Long tripId, @PathVariable Long memberId, HttpSession session) {
        if (getLoginMemberId(session) == null)
            return ResponseEntity.status(401).body(Map.of("success", false));
        try {
            tripService.kickMember(tripId, memberId);
            return ResponseEntity.ok(Map.of("success", true));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }

    // 스스로 나가기
    @DeleteMapping("/{tripId}/leave")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> leaveTrip(
    		@PathVariable("tripId") Long tripId, HttpSession session) {
        Long loginId = getLoginMemberId(session);
        if (loginId == null)
            return ResponseEntity.status(401).body(Map.of("success", false));
        tripService.leaveTrip(tripId, loginId);
        return ResponseEntity.ok(Map.of("success", true));
    }

    @PostMapping("/{tripId}/scrap")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> scrapTrip(
    		@PathVariable("tripId") Long tripId, HttpSession session) {
        Long loginMemberId = getLoginMemberId(session);
        if (loginMemberId == null) return ResponseEntity.status(401).body(Map.of("success", false));
        Long newTripId = tripService.cloneTrip(tripId, loginMemberId);
        return ResponseEntity.ok(Map.of("success", true, "newTripId", newTripId));
    }

    @GetMapping("/tag/search")
    @ResponseBody
    public List<String> searchTags(@RequestParam("keyword") String keyword) {
        return tripService.searchTags(keyword);
    }

    // 환영 모달 읽음 처리 (1회성)
    @PatchMapping("/{tripId}/welcome/done")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> markWelcomeDone(
            @PathVariable("tripId") Long tripId, HttpSession session) {
        Long loginId = getLoginMemberId(session);
        if (loginId == null)
            return ResponseEntity.status(401).body(Map.of("success", false));
        tripMemberRepository.markFirstVisitDone(tripId, loginId);
        return ResponseEntity.ok(Map.of("success", true));
    }

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
