package com.tripan.app.controller;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
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

import com.tripan.app.common.PaginateUtil;
import com.tripan.app.domain.dto.AccommodationDetailDto;
import com.tripan.app.domain.dto.AccommodationDto;
import com.tripan.app.domain.dto.AdSearchConditionDto;
import com.tripan.app.domain.dto.CheckoutCouponDto;
import com.tripan.app.domain.dto.MemberDto;
import com.tripan.app.domain.dto.ReservationRequestDto;
import com.tripan.app.domain.dto.ReviewDto;
import com.tripan.app.domain.dto.ReviewStatsDto;
import com.tripan.app.domain.dto.RoomDto;
import com.tripan.app.service.AccommodationService;
import com.tripan.app.service.CouponService;
import com.tripan.app.service.PointService;
import com.tripan.app.service.PortOneService;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/accommodation/*")
@RequiredArgsConstructor
public class AccommodationController {
	private final AccommodationService accommodationService;
	private final PointService pointService;
	private final PortOneService portOneService;
	@Autowired
	@Qualifier("userCouponService") 
	private final CouponService couponService;
	private final PaginateUtil paginateUtil;
	
	@Value("${tripan.api.kakao-map-api-key}")
	private String kakaoApiKey;
	
	@Value("${portone.imp.code}")
	private String impCode;
	
	@GetMapping("home") 
    public String home(Model model, HttpSession session) {
        AdSearchConditionDto condition = new AdSearchConditionDto();
        condition.setSort("POPULAR"); 
        condition.setOffset(0);
        condition.setSize(10);         
        
        
        MemberDto loginUser = (MemberDto) session.getAttribute("loginUser");
        if (loginUser != null) {
            condition.setMemberId(loginUser.getMemberId());
        }
        
        
        List<AccommodationDto> popularList = accommodationService.searchAccommodations(condition);
        model.addAttribute("popularList", popularList);
        
        return "accommodation/home";
    }
	
    @GetMapping("list")
    public String list(@RequestParam(value = "region", defaultValue = "서울 전체") String region,
    		Model model) {
    	
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
    public String detail(@PathVariable("id") Long id, 
                         @RequestParam(value = "checkin", required = false) String checkin,
                         @RequestParam(value = "checkout", required = false) String checkout,
                         HttpSession session, Model model) {
        
        MemberDto loginUser = (MemberDto) session.getAttribute("loginUser");
        Long memberId = (loginUser != null) ? loginUser.getMemberId() : null;

        AccommodationDetailDto detail = accommodationService.getAccommodationDetail(id, memberId, checkin, checkout);
        model.addAttribute("detail", detail);
        
        // 비활성화된 숙소일 경우
        if (detail == null) {
            model.addAttribute("message", "현재 비활성화되었거나 존재하지 않는 숙소입니다.");
            return "error/error2";
        }

        List<String> bookedDates = accommodationService.getFullyBookedDates(id);
        model.addAttribute("bookedDates", bookedDates);
        
        ReviewStatsDto reviewStats = accommodationService.getReviewStats(id);
        model.addAttribute("reviewStats", reviewStats);
        
        int bookmarkCount = accommodationService.getBookmarkCount(id);
        model.addAttribute("bookmarkCount", bookmarkCount);
        
        List<String> reviewPhotos = accommodationService.getReviewPhotos(id, null);
        model.addAttribute("reviewPhotos", reviewPhotos);
        
        List<ReviewDto> topReviews = accommodationService.getReviewList(id, "high", null, 0, 3);
        model.addAttribute("topReviews", topReviews);
        
        try {
            List<Map<String, Object>> downloadableCoupons = couponService.getDownloadableCoupons(id, memberId);
            model.addAttribute("couponCount", downloadableCoupons != null ? downloadableCoupons.size() : 0);
        } catch (Exception e) {
            model.addAttribute("couponCount", 0);
        }
        
        model.addAttribute("kakaoApiKey", kakaoApiKey);
        
        return "accommodation/detail";
    }
    
    @GetMapping("room/detail/api/{roomId}")
    @ResponseBody
    public Map<String, Object> getRoomDetailModalApi(@PathVariable("roomId") String roomId) {
        Map<String, Object> response = new HashMap<>();
        try {
            Map<String, Object> roomInfo = accommodationService.getRoomDetailWithFacilities(roomId);
            List<String> roomImages = accommodationService.getRoomImagesByRoomId(roomId);
            
            response.put("success", true);
            response.put("room", roomInfo);
            response.put("images", roomImages);
        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "객실 정보를 불러오는 데 실패했습니다.");
        }
        return response;
    }
    
    @GetMapping("reservation")
    public String reservationForm(
            @RequestParam("roomId") String roomId,
            @RequestParam(value = "checkin", defaultValue = "") String checkin,
            @RequestParam(value = "checkout", defaultValue = "") String checkout,
            @RequestParam(value = "adult", defaultValue = "1") int adult,
            @RequestParam(value = "child", defaultValue = "0") int child,
            HttpSession session,
            Model model) {

        model.addAttribute("roomId", roomId);
        model.addAttribute("checkin", checkin);
        model.addAttribute("checkout", checkout);
        model.addAttribute("adult", adult);
        model.addAttribute("child", child);

        RoomDto room = accommodationService.findRoomById(roomId);
        
        if (room == null) {
            model.addAttribute("message", "현재 이용할 수 없는(비활성화된) 객실입니다.");
            return "error/error2";
        }
        
        model.addAttribute("room", room);
        
        long nights = 1; 
        if (!checkin.isEmpty() && !checkout.isEmpty()) {
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
            LocalDate inDate = LocalDate.parse(checkin, formatter);
            LocalDate outDate = LocalDate.parse(checkout, formatter);
            
            nights = ChronoUnit.DAYS.between(inDate, outDate);
            if (nights <= 0) nights = 1; 
        }
        
        int totalGuest = adult + child;
        int extraGuest = Math.max(0, totalGuest - room.getRoomBaseCount()); 
        long extraFeePerNight = extraGuest * 20000;
        
        long totalAmount = (room.getAmount() + extraFeePerNight) * nights;
        
        MemberDto loginUser = (MemberDto) session.getAttribute("loginUser");
        if (loginUser != null) {
        	List<CheckoutCouponDto> myCoupons = couponService.getCouponsForCheckout(
        	        loginUser.getMemberId(), room.getPlaceId(), roomId, totalAmount
        	    );
        	    model.addAttribute("myCoupons", myCoupons);
        	
            long currentPoint = pointService.getLatestPoint(loginUser.getMemberId());
            long limitPoint = (long) (totalAmount * 0.3);
            
            long maxUsablePoint = 0;
            
            if (currentPoint >= 1000) {
                maxUsablePoint = Math.min(currentPoint, limitPoint);
                
                maxUsablePoint = (maxUsablePoint / 100) * 100;
            }

            model.addAttribute("currentPoint", currentPoint);
            model.addAttribute("maxUsablePoint", maxUsablePoint);
        }
        
        model.addAttribute("impCode", impCode);
        model.addAttribute("nights", nights);
        model.addAttribute("amount", totalAmount);

        return "accommodation/reservation";
    }
    
    @PostMapping("check-lock")
    @ResponseBody
    public Map<String, Object> checkLock(@RequestBody Map<String, String> payload, HttpSession session) {
        String roomId = payload.get("roomId");
        String checkin = payload.get("checkin");
        String checkout = payload.get("checkout");
        String sessionId = session.getId(); 

        boolean isLocked = accommodationService.acquireLock(roomId, checkin, checkout, sessionId);

        Map<String, Object> response = new HashMap<>();
        response.put("success", isLocked);
        if (!isLocked) {
        	response.put("message", "현재 결제가 몰려 해당 객실의 남은 방이 없습니다. 잠시 후 다시 시도해 주세요.");
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
        
        Map<String, Object> response = new HashMap<>();

        try {
        	MemberDto loginUser = (MemberDto) session.getAttribute("loginUser");

        	if (loginUser == null) {
                response.put("success", false);
                response.put("message", "로그인이 풀렸습니다. 다시 로그인해 주세요.");
                return response;
            }
            
            requestDto.setMemberId(loginUser.getMemberId()); 
            
            String sessionId = session.getId();

            accommodationService.processReservation(requestDto, sessionId);
            
            response.put("success", true); 

        } catch (Exception e) {
            e.printStackTrace(); 
            
            response.put("success", false);
            response.put("message", "서버 저장 중 문제가 발생하여 결제가 자동 취소(환불) 처리됩니다.");
            
            try {
                portOneService.cancelPayment(requestDto.getMerchantUid(), "서버 DB 저장 실패로 인한 자동 환불", requestDto.getAmount());
                System.out.println("🚨 안전하게 자동 환불 처리 완료: " + requestDto.getMerchantUid());
                
            } catch (Exception cancelEx) {
                cancelEx.printStackTrace();
                response.put("message", "예약 처리 중 오류가 발생했습니다. 환불이 진행되지 않은 경우 고객센터로 문의해 주세요. (주문번호: " + requestDto.getMerchantUid() + ")");
            }
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
            response.put("isBookmarked", isBookmarked);
        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "오류가 발생했습니다.");
        }
        return response;
    }
    
    
    // 리뷰 섹션
    
    @GetMapping("review/write/{reservationId}")
    public String writeForm(@PathVariable("reservationId") Long reservationId, 
                            HttpSession session, 
                            Model model) {
        
        MemberDto loginUser = (MemberDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            return "redirect:/member/login";
        }

        ReservationRequestDto reservationInfo = accommodationService.getReservationInfobyId(reservationId);
        
        if (reservationInfo == null) {
            model.addAttribute("message", "존재하지 않는 예약입니다.");
            return "error/error2";
        }

        if (!loginUser.getMemberId().equals(reservationInfo.getMemberId())) {
            model.addAttribute("message", "본인의 예약 내역만 리뷰를 작성할 수 있습니다.");
            return "error/error2";
        }

        if (!"SUCCESS".equals(reservationInfo.getStatus())) {
            model.addAttribute("message", "정상적으로 이용이 완료된 예약만 리뷰 작성이 가능합니다.");
            return "error/error2";
        }

        LocalDate outDate = LocalDate.parse(reservationInfo.getCheckout());
        LocalDate today = LocalDate.now();

        if (!today.isAfter(outDate)) {
            model.addAttribute("message", "리뷰는 체크아웃 이후에 작성할 수 있습니다.");
            return "error/error2";
        }

        long daysSinceCheckout = ChronoUnit.DAYS.between(outDate, today);
        if (daysSinceCheckout > 30) {
            model.addAttribute("message", "리뷰 작성 기간(체크아웃 후 30일)이 지났습니다.");
            return "error/error2";
        }

        boolean isReviewExists = accommodationService.checkReviewExistsByReservationId(reservationId);
        if (isReviewExists) {
            model.addAttribute("message", "이미 해당 예약에 대한 리뷰를 작성하셨습니다.");
            return "error/error2";
        }


        RoomDto room = accommodationService.findRoomById(reservationInfo.getRoomId());
        long nights = ChronoUnit.DAYS.between(LocalDate.parse(reservationInfo.getCheckin()), outDate);
        
        model.addAttribute("mode", "write");
        model.addAttribute("reservationInfo", reservationInfo);
        model.addAttribute("nights", nights);
        model.addAttribute("room", room); 
        
        return "accommodation/review/review_form"; 
    }
    
    @PostMapping("review/submit")
    public String submitReview(ReviewDto dto, HttpSession session, Model model) {
    	
        MemberDto loginUser = (MemberDto) session.getAttribute("loginUser");
        
        if (loginUser == null) {
            return "redirect:/member/login";
        }

        dto.setMemberId(loginUser.getMemberId());

        try {
            accommodationService.insertReview(dto);
        } catch (Exception e) {
            e.printStackTrace();
            model.addAttribute("message", "리뷰 등록 중 오류가 발생했습니다.");
            return "error/error2";
        }

        return "redirect:/accommodation/detail/" + dto.getPlaceId();
    }
    
    @GetMapping("review/list/{placeId}")
    public String reviewList(@PathVariable("placeId") Long placeId, 
                             @RequestParam(value = "page", defaultValue = "1") int current_page, // 🚀 현재 페이지 파라미터 추가
                             @RequestParam(value = "sort", defaultValue = "latest") String sort,
                             @RequestParam(value = "roomId", required = false) String roomId, 
                             HttpServletRequest req, 
                             Model model) {
        
        AccommodationDetailDto placeInfo = accommodationService.getAccommodationDetail(placeId, null, null, null);
        ReviewStatsDto stats = accommodationService.getReviewStats(placeId);
        List<RoomDto> roomList = accommodationService.getRoomsByPlaceId(placeId);
        
        int size = 5; 
        int dataCount = accommodationService.getReviewCount(placeId, roomId); 
        int total_page = paginateUtil.pageCount(dataCount, size); 
        
        if (current_page > total_page && total_page > 0) {
            current_page = total_page;
        }
        
        int offset = (current_page - 1) * size;
        if(offset < 0) offset = 0;
        
        List<ReviewDto> reviewList = accommodationService.getReviewList(placeId, sort, roomId, offset, size);
        
        String cp = req.getContextPath();
        String list_url = cp + "/accommodation/review/list/" + placeId + "?sort=" + sort;
        if (roomId != null && !roomId.isEmpty()) {
            list_url += "&roomId=" + roomId;
        }
        
        String paging = paginateUtil.paging(current_page, total_page, list_url);
        
        
        model.addAttribute("placeId", placeId);
        model.addAttribute("placeInfo", placeInfo);
        model.addAttribute("stats", stats);
        model.addAttribute("reviewList", reviewList);
        model.addAttribute("roomList", roomList);
        model.addAttribute("sort", sort);
        model.addAttribute("roomId", roomId);
        
        model.addAttribute("page", current_page);
        model.addAttribute("dataCount", dataCount);
        model.addAttribute("paging", paging); 
        
        return "accommodation/review/review_list"; 
    }
    
    @PostMapping("review/delete")
    public String deleteReview(@RequestParam("reviewId") Long reviewId, 
                               @RequestParam("placeId") Long placeId, 
                               HttpSession session,
                               Model model) {
                               
        MemberDto loginUser = (MemberDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            return "redirect:/member/login";
        }
        
        try {
            accommodationService.deleteReview(reviewId); 
        } catch (Exception e) {
            e.printStackTrace();
            model.addAttribute("message", "리뷰 삭제 중 오류가 발생했습니다.");
            return "error/error2";
        }
        
        return "redirect:/accommodation/review/list/" + placeId;
    }
    
    
    @GetMapping("review/update/{reviewId}")
    public String updateForm(@PathVariable("reviewId") Long reviewId, HttpSession session, Model model) {
        MemberDto loginUser = (MemberDto) session.getAttribute("loginUser");
        if (loginUser == null) return "redirect:/member/login";

        ReviewDto review = accommodationService.getReviewById(reviewId);
        if (review == null || !review.getMemberId().equals(loginUser.getMemberId())) {
            model.addAttribute("message", "수정 권한이 없습니다.");
            return "error/error2";
        }

        model.addAttribute("mode", "update");
        model.addAttribute("review", review);
        return "accommodation/review/review_form";
    }

    @PostMapping("review/update")
    public String updateReviewSubmit(ReviewDto dto, HttpSession session, Model model) {
        MemberDto loginUser = (MemberDto) session.getAttribute("loginUser");
        if (loginUser == null) return "redirect:/member/login";

        dto.setMemberId(loginUser.getMemberId()); 

        try {
            accommodationService.updateReview(dto);
        } catch (Exception e) {
            e.printStackTrace();
            model.addAttribute("message", "리뷰 수정 중 오류가 발생했습니다.");
            return "error/error2";
        }

        return "redirect:/accommodation/review/list/" + dto.getPlaceId();
    }
    
    @GetMapping("review/photos/{placeId}")
    @ResponseBody
    public List<String> getReviewPhotos(@PathVariable("placeId") Long placeId, 
                                        @RequestParam(value = "roomId", required = false) String roomId) {
        return accommodationService.getReviewPhotos(placeId, roomId);
    }
    
    @PostMapping("cancel")
    @ResponseBody
    public Map<String, Object> cancelReservation(@RequestBody Map<String, Long> payload, HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        MemberDto loginUser = (MemberDto) session.getAttribute("loginUser");
        
        if (loginUser == null) {
            response.put("success", false);
            response.put("message", "로그인이 풀렸습니다. 다시 로그인해 주세요.");
            return response;
        }

        Long reservationId = payload.get("reservationId");
        try {
            accommodationService.cancelReservation(reservationId, loginUser.getMemberId());
            response.put("success", true);
        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", e.getMessage());
        }
        return response;
    }
    
    @GetMapping("coupons/{placeId}")
    @ResponseBody
    public Map<String, Object> getDownloadableCoupons(@PathVariable("placeId") Long placeId, HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        MemberDto loginUser = (MemberDto) session.getAttribute("loginUser");
        Long memberId = (loginUser != null) ? loginUser.getMemberId() : null;

        try {
            List<Map<String, Object>> coupons = couponService.getDownloadableCoupons(placeId, memberId);
            response.put("success", true);
            response.put("coupons", coupons);
        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
        }
        return response;
    }

    @PostMapping("coupon/download")
    @ResponseBody
    public Map<String, Object> downloadCoupon(@RequestBody Map<String, Long> payload, HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        MemberDto loginUser = (MemberDto) session.getAttribute("loginUser");

        if (loginUser == null) {
            response.put("success", false);
            response.put("message", "로그인이 필요한 서비스입니다.");
            return response;
        }

        Long couponId = payload.get("couponId");
        try {
            couponService.downloadCoupon(loginUser.getMemberId(), couponId);
            response.put("success", true);
            response.put("message", "쿠폰이 발급되었습니다! 🥳");
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", e.getMessage()); 
        }
        return response;
    }
    
}