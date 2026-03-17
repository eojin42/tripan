package com.tripan.app.controller;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.Map;
import java.util.Optional;

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
import com.tripan.app.service.TripMemberService;
import com.tripan.app.service.TripService;
import com.tripan.app.trip.domain.entity.TripMember;
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
    private final TripMemberService tripMemberService;
    
    @Value("${tripan.api.kakao-map-api-key}")
    private String kakaoMapKey;

    @GetMapping("/trip_create")
    public String create(Model model) {
        return "trip/trip_create";
    }

    @GetMapping("/{tripId}/workspace")
    public String workspace(
            @PathVariable("tripId") Long tripId,
            HttpSession session, Model model) {

        Long loginMemberIdForWelcome = getLoginMemberId(session);
        if (loginMemberIdForWelcome == null) return "redirect:/member/login";

        // 멤버가 아니거나 강퇴/나간 상태면 즉시 튕겨내기
        Optional<TripMember> myMemberInfo = tripMemberRepository.findByTripIdAndMemberId(tripId, loginMemberIdForWelcome);
        
        if (!myMemberInfo.isPresent() || 
            "DECLINED".equals(myMemberInfo.get().getInvitationStatus()) || 
            "KICKED".equals(myMemberInfo.get().getInvitationStatus())) { // 👈 KICKED 조건 추가!
            
            session.setAttribute("toastMsg", "접근 권한이 없거나 강퇴된 여행입니다.");
            return "redirect:/trip/my_trips"; 
        }

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

        // 환영 모달: 현재 유저의 isFirstVisit 확인
        boolean showWelcome = Integer.valueOf(1).equals(myMemberInfo.get().getIsFirstVisit());
        model.addAttribute("showWelcome",  showWelcome);
        
        // 🚨 2. 내 권한(OWNER, EDITOR, VIEWER)을 JSP로 넘기기
        String myRole = myMemberInfo.get().getRole();
        model.addAttribute("myMemberId", loginMemberIdForWelcome);
        model.addAttribute("memberRole", myRole);
        model.addAttribute("isOwner", "OWNER".equals(myRole));

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
            
            wsPublisher.publish(tripId, "MEMBER_JOINED", loginMemberId,
                    nick != null ? nick : "새 멤버",
                    WorkspaceEventPublisher.payload("nickname", nick != null ? nick : "새 멤버"));
            
            notificationService.notifyAll(tripId, loginMemberId, nick + "님이 여행에 합류했어요 🎉", "ACCEPT");
            notificationService.notifyOne(tripId, loginMemberId, loginMemberId, "여행 워크스페이스에 합류하셨네요! 환영합니다 ✈️", "SYSTEM");
            
            return "redirect:/trip/" + tripId + "/workspace";

        } catch (IllegalStateException e) {
            String msg = e.getMessage();
            if (msg != null && msg.startsWith("ALREADY_JOINED:")) {
                String existingTripId = msg.split(":")[1];
                return "redirect:/trip/" + existingTripId + "/workspace"; 
            }
            session.setAttribute("toastMsg", "🚨 " + msg);
            return "redirect:/trip/my-trips";
            
        } catch (Exception e) {
            e.printStackTrace(); 
            session.setAttribute("toastMsg", "유효하지 않은 초대 링크입니다.");
            return "redirect:/trip/my-trips";
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

    
    @DeleteMapping("/{tripId}/member/{memberId}/decline")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> declineInvite(
            @PathVariable("tripId") Long tripId, @PathVariable Long memberId) {
        try {
            tripMemberService.leaveTrip(tripId, memberId); 
            return ResponseEntity.ok(Map.of("success", true));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
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

    // 🚨 여기서 방금 전 뺀 "없는 메서드" 대신, 서비스에 만든 확실한 메서드를 호출합니다!
    @PatchMapping("/{tripId}/invite-code")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> regenerateInviteCode(@PathVariable("tripId") Long tripId, HttpSession session) {
        Long loginId = getLoginMemberId(session);
        if (loginId == null) return ResponseEntity.status(401).body(Map.of("success", false));
        try {
            String newCode = tripService.regenerateInviteCode(tripId);
            return ResponseEntity.ok(Map.of("success", true, "newCode", newCode));
        } catch(Exception e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
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