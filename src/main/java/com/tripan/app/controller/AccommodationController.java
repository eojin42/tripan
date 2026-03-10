package com.tripan.app.controller;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

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
	
	@GetMapping("home")
	public String main() {
		
		return "accommodation/home";
	}
	
	// 숙소 리스트 페이지 (지역 선택 시 이동)
    @GetMapping("/list")
    public String list(@RequestParam(value = "region", defaultValue = "서울 전체") String region,
    		Model model) {
        
        model.addAttribute("region", region);
        
        return "accommodation/list";
    }
    
    @PostMapping("/search")
    @ResponseBody 
    public List<AccommodationDto> searchAccommodations(@RequestBody AdSearchConditionDto condition) {

        return accommodationService.searchAccommodations(condition);
    }
    
    @GetMapping("/detail/{id}")
    public String detail(@PathVariable("id") Long id, Model model) {
        
        AccommodationDetailDto detail = accommodationService.getAccommodationDetail(id);
        
        model.addAttribute("detail", detail);
        
        return "accommodation/detail";
    }
    
    @GetMapping("/reservation")
    public String reservationForm(
            @RequestParam("roomId") String roomId,
            @RequestParam(value = "checkin", defaultValue = "") String checkin,
            @RequestParam(value = "checkout", defaultValue = "") String checkout,
            @RequestParam(value = "adult", defaultValue = "2") int adult,
            @RequestParam(value = "child", defaultValue = "0") int child,
            Model model) {

    	// 1. 파라미터 기본 전달
        model.addAttribute("roomId", roomId);
        model.addAttribute("checkin", checkin);
        model.addAttribute("checkout", checkout);
        model.addAttribute("adult", adult);
        model.addAttribute("child", child);

        // 2. DB에서 실제 객실 정보 가져오기
        RoomDto room = accommodationService.findRoomById(roomId);
        model.addAttribute("roomName", room.getRoomName());
        
        // 3. 숙박 일수(Nights) 계산 로직
        long nights = 1; // 기본 1박
        if (!checkin.isEmpty() && !checkout.isEmpty()) {
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
            LocalDate inDate = LocalDate.parse(checkin, formatter);
            LocalDate outDate = LocalDate.parse(checkout, formatter);
            
            // 날짜 차이 계산 (예: 10일 체크인, 12일 체크아웃이면 2박)
            nights = ChronoUnit.DAYS.between(inDate, outDate);
            if (nights <= 0) nights = 1; // 오류 방지용 최소 1박
        }
        
        // 4. 총 결제 금액 계산 = (1박 가격 * 숙박 일수)
        long totalAmount = room.getAmount() * nights;
        
        model.addAttribute("nights", nights);
        model.addAttribute("amount", totalAmount); // 폼에서 보여줄 최종 금액

        return "accommodation/reservation";
    }
    
    @PostMapping("/check-lock")
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
    
    @PostMapping("/release-lock")
    @ResponseBody
    public void releaseLock(@RequestBody Map<String, String> payload, HttpSession session) {
        String roomId = payload.get("roomId");
        String checkin = payload.get("checkin");
        String sessionId = session.getId(); 
        
        // 사용자가 폼을 벗어날 때 즉시 락을 풀어줌
        accommodationService.releaseLock(roomId, checkin, sessionId);
    }
    
    
    @PostMapping("/complete")
    @ResponseBody
    public Map<String, Object> completeReservation(
            @RequestBody ReservationRequestDto requestDto, 
            HttpSession session) {
        
        System.out.println("💳 프론트에서 넘어온 결제 데이터: " + requestDto);

        Map<String, Object> response = new HashMap<>();

        try {
            // 1. 세션에서 로그인한 유저의 ID를 꺼내서 DTO에 넣어줍니다.
            // UserDto loginUser = (UserDto) session.getAttribute("loginUser");
            // requestDto.setUserId(loginUser.getUserId());
            
            // (임시 테스트용 강제 세팅 - 나중에 지우세요!)
            requestDto.setMemberId(1L); 

            // 2. 대망의 트랜잭션 서비스 실행! (여기서 4개 테이블에 쫙 들어감)
            accommodationService.processReservation(requestDto);
            
            // 3. 무사히 성공했다면 프론트엔드로 성공 신호 보내기
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
}
