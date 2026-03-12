package com.tripan.app.controller;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.tripan.app.domain.dto.AccommodationDetailDto;
import com.tripan.app.domain.dto.AccommodationDto;
import com.tripan.app.domain.dto.AdSearchConditionDto;
import com.tripan.app.domain.dto.MemberDto;
import com.tripan.app.domain.dto.ReservationRequestDto;
import com.tripan.app.domain.dto.RoomDto;
import com.tripan.app.service.AccommodationService;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/accommodation/*")
@RequiredArgsConstructor
public class AccommodationController {
	private final AccommodationService accommodationService;
	
	@Value("${tripan.api.kakao-map-api-key}")
	private String kakaoApiKey;
	
	@GetMapping("home")
	public String main() {
		
		return "accommodation/home";
	}
	
    @GetMapping("list")
    public String list(@RequestParam(value = "region", defaultValue = "서울 전체") String region,
    		Model model) {
        System.out.println(kakaoApiKey);
    	
        model.addAttribute("region", region);
        
        model.addAttribute("kakaoApiKey", kakaoApiKey);
        
        return "accommodation/list";
    }
    
    @PostMapping("search")
    @ResponseBody 
    public List<AccommodationDto> searchAccommodations(@RequestBody AdSearchConditionDto condition,
    										HttpSession session) {
    	
    	MemberDto loginUser = (MemberDto) session.getAttribute("loginUser");
        if (loginUser != null) {
            condition.setMemberId(loginUser.getMemberId());
        }
        
        return accommodationService.searchAccommodations(condition);
    }
    
    @GetMapping("detail/{id}")
    public String detail(@PathVariable("id") Long id, HttpSession session, Model model) {
        
    	MemberDto loginUser = (MemberDto) session.getAttribute("loginUser");
        Long memberId = (loginUser != null) ? loginUser.getMemberId() : null;

        AccommodationDetailDto detail = accommodationService.getAccommodationDetail(id, memberId);
        model.addAttribute("detail", detail);

        return "accommodation/detail";
    }
    
    @GetMapping("reservation")
    public String reservationForm(
            @RequestParam("roomId") String roomId,
            @RequestParam(value = "checkin", defaultValue = "") String checkin,
            @RequestParam(value = "checkout", defaultValue = "") String checkout,
            @RequestParam(value = "adult", defaultValue = "1") int adult,
            @RequestParam(value = "child", defaultValue = "0") int child,
            Model model) {

        model.addAttribute("roomId", roomId);
        model.addAttribute("checkin", checkin);
        model.addAttribute("checkout", checkout);
        model.addAttribute("adult", adult);
        model.addAttribute("child", child);

        RoomDto room = accommodationService.findRoomById(roomId);
        model.addAttribute("roomName", room.getRoomName());
        
        // 숙박 일수(Nights) 계산 로직
        long nights = 1; 
        if (!checkin.isEmpty() && !checkout.isEmpty()) {
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
            LocalDate inDate = LocalDate.parse(checkin, formatter);
            LocalDate outDate = LocalDate.parse(checkout, formatter);
            
            nights = ChronoUnit.DAYS.between(inDate, outDate);
            if (nights <= 0) nights = 1; // 오류 방지용 최소 1박
        }
        
        int totalGuest = adult + child;
        int extraGuest = Math.max(0, totalGuest - room.getRoomBaseCount()); 
        long extraFeePerNight = extraGuest * 20000;
        
        // 4. 총 결제 금액 계산 = (1박 가격 * 숙박 일수)
        long totalAmount = (room.getAmount() + extraFeePerNight) * nights;
        
        model.addAttribute("nights", nights);
        model.addAttribute("amount", totalAmount); // 폼에서 보여줄 최종 금액

        return "accommodation/reservation";
    }
    
    @PostMapping("check-lock")
    @ResponseBody
    public Map<String, Object> checkLock(@RequestBody Map<String, String> payload, HttpSession session) {
        String roomId = payload.get("roomId");
        String checkin = payload.get("checkin");
        String sessionId = session.getId(); 

        boolean isLocked = accommodationService.acquireLock(roomId, checkin, sessionId);

        Map<String, Object> response = new HashMap<>();
        response.put("success", isLocked);
        if (!isLocked) {
            response.put("message", "현재 다른 사용자가 결제를 진행 중인 객실입니다. 5분 뒤에 다시 시도해 주세요.");
        }
        return response;
    }
    
    @PostMapping("release-lock")
    @ResponseBody
    public void releaseLock(@RequestBody Map<String, String> payload, HttpSession session) {
        String roomId = payload.get("roomId");
        String checkin = payload.get("checkin");
        String sessionId = session.getId(); 
        
        // 사용자가 폼을 벗어날 때 즉시 락을 풀어줌
        accommodationService.releaseLock(roomId, checkin, sessionId);
    }
    
    
    @PostMapping("complete")
    @ResponseBody
    public Map<String, Object> completeReservation(
            @RequestBody ReservationRequestDto requestDto, 
            HttpSession session) {
        
        System.out.println("💳 프론트에서 넘어온 결제 데이터: " + requestDto);

        Map<String, Object> response = new HashMap<>();

        try {
        	MemberDto loginUser = (MemberDto) session.getAttribute("loginUser");

        	if (loginUser == null) {
                response.put("success", false);
                response.put("message", "로그인이 풀렸습니다. 다시 로그인해 주세요.");
                return response;
            }
            
            requestDto.setMemberId(loginUser.getMemberId()); 

            accommodationService.processReservation(requestDto);
            
            response.put("success", true); 

        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "결제는 완료되었으나 서버 저장 중 에러가 발생했습니다.");
            
            // 🚨 실무에서는 여기에 "포트원 결제 취소 API"를 호출하는 로직이 들어갑니다. (에러 났으니 환불해 줘야 함!)
            // portoneService.cancelPayment(requestDto.getImpUid(), "서버 DB 저장 실패로 인한 자동 환불");
        }
        
        return response;
    }
    
    @PostMapping("bookmark")
    @ResponseBody
    public Map<String, Object> toggleBookmark(@RequestBody Map<String, Long> payload, HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        
        MemberDto loginUser = (MemberDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            response.put("success", false);
            response.put("message", "로그인이 필요한 서비스입니다.");
            return response;
        }

        Long placeId = payload.get("placeId");
        try {
            boolean isBookmarked = accommodationService.toggleBookmark(placeId, loginUser.getMemberId());
            response.put("success", true);
            response.put("isBookmarked", isBookmarked); // 뷰단에서 색깔 바꿀 때 사용
        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "오류가 발생했습니다.");
        }
        return response;
    }
}
