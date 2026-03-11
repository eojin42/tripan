package com.tripan.app.controller;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.Map;

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
import com.tripan.app.service.TripService;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/trip")
@RequiredArgsConstructor
public class TripController {

    private final TripService tripService;


    // 여행 생성 폼 화면
    @GetMapping("/trip_create")
    public String create(Model model) {
        return "trip/trip_create";
    }

    // 워크스페이스 화면 진입
    @GetMapping("/{tripId}/workspace")
    public String workspace(@PathVariable("tripId") Long tripId, HttpSession session, Model model) {
        if (getLoginMemberId(session) == null) return "redirect:/member/login";

        TripDto tripDto = tripService.getTripDetails(tripId);

        // 박수 계산
        long nights = ChronoUnit.DAYS.between(
        	    LocalDate.parse(tripDto.getStartDate().substring(0, 10)),
        	    LocalDate.parse(tripDto.getEndDate().substring(0, 10))
        	);
        String tripNights = nights == 0 ? "당일치기" : (nights + "박 " + (nights + 1) + "일");

        model.addAttribute("tripId",    tripId);
        model.addAttribute("tripDto",   tripDto);
        model.addAttribute("tripNights", tripNights);
        return "trip/workspace";
    }

    // 여행 생성
    @PostMapping("/create")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> createTrip(@RequestBody TripCreateDto dto, HttpSession session) {
        Long loginMemberId = getLoginMemberId(session);
        
        // 디버깅용 
        System.out.println("====> [DEBUG] DTO Data: " + dto.getTitle() + ", Tags: " + dto.getTags());
        
        if (loginMemberId == null) return ResponseEntity.status(401).body(Map.of("success", false, "message", "로그인이 필요합니다"));
        
        try {
            Long tripId = tripService.createTrip(dto, loginMemberId);
            return ResponseEntity.ok(Map.of("success", true, "tripId", tripId));
        } catch (Exception e) {
            // 디버깅용 
        	e.printStackTrace(); 
            
            System.err.println("====> [ERROR] createTrip 실패: " + e.getMessage());
            
            return ResponseEntity.status(500).body(Map.of("success", false, "message", e.getMessage()));
        }
    }

    // 여행 수정 
    @PatchMapping("/{tripId}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> updateTrip(@PathVariable Long tripId, @RequestBody TripCreateDto dto, HttpSession session) {
        if (getLoginMemberId(session) == null) return ResponseEntity.status(401).body(Map.of("success", false));

        try {
            tripService.updateTrip(tripId, dto);
            return ResponseEntity.ok(Map.of("success", true));
        } catch (Exception e) {
            return ResponseEntity.status(500).body(Map.of("success", false, "message", e.getMessage()));
        }
    }
    
    // 여행 삭제 
    @DeleteMapping("/{tripId}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> deleteTrip(@PathVariable Long tripId, HttpSession session) {
        if (getLoginMemberId(session) == null) return ResponseEntity.status(401).body(Map.of("success", false));
        tripService.deleteTrip(tripId);
        return ResponseEntity.ok(Map.of("success", true));
    }


    // 링크 공유 초대 수락 (/trip/invite/{inviteCode})
    @GetMapping("/invite/{inviteCode}")
    public String acceptInviteLink(@PathVariable String inviteCode, HttpSession session) {
        Long loginMemberId = getLoginMemberId(session);
        if (loginMemberId == null) {
            session.setAttribute("redirectAfterLogin", "/trip/invite/" + inviteCode);
            return "redirect:/member/login";
        }
        try {
            Long tripId = tripService.joinTripViaLink(inviteCode, loginMemberId);
            return "redirect:/trip/" + tripId + "/workspace";
        } catch (Exception e) {
            return "redirect:/?error=invalid_invite";
        }
    }

    // 아이디 검색 초대 (PENDING)
    @PostMapping("/{tripId}/invite/search")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> inviteBySearch(@PathVariable Long tripId, @RequestBody Map<String, Long> body, HttpSession session) {
        if (getLoginMemberId(session) == null) return ResponseEntity.status(401).body(Map.of("success", false));

        try {
            tripService.inviteMemberToTrip(tripId, body.get("targetMemberId"));
            return ResponseEntity.ok(Map.of("success", true));
        } catch (IllegalStateException e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }

    // 초대 수락 (알림 클릭 → ACCEPTED)
    @PatchMapping("/{tripId}/member/{memberId}/accept")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> acceptInvite(@PathVariable Long tripId, @PathVariable Long memberId) {
        tripService.acceptTripInvitation(tripId, memberId);
        return ResponseEntity.ok(Map.of("success", true));
    }

    // 담아오기 (딥 카피)
    @PostMapping("/{tripId}/scrap")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> scrapTrip(@PathVariable Long tripId, HttpSession session) {
        Long loginMemberId = getLoginMemberId(session);
        if (loginMemberId == null) return ResponseEntity.status(401).body(Map.of("success", false));

        Long newTripId = tripService.cloneTrip(tripId, loginMemberId);
        return ResponseEntity.ok(Map.of("success", true, "newTripId", newTripId));
    }

    // 태그 자동완성
    @GetMapping("/tag/search")
    @ResponseBody
    public List<String> searchTags(@RequestParam String keyword) {
        return tripService.searchTags(keyword);
    }


    private Long getLoginMemberId(HttpSession session) {
        Object user = session.getAttribute("loginUser");
        if (user == null) return null;
        try {
            return (Long) user.getClass().getMethod("getMemberId").invoke(user);
        } catch (Exception e) {
            return null;
        }
    }
}