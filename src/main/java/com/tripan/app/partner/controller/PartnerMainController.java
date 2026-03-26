package com.tripan.app.partner.controller;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import com.tripan.app.domain.dto.AccommodationDetailDto;
import com.tripan.app.partner.domain.dto.PartnerCouponDto;
import com.tripan.app.partner.domain.dto.PartnerInfoDto;
import com.tripan.app.partner.domain.dto.PartnerReviewDto;
import com.tripan.app.partner.domain.dto.PartnerRoomDto;
import com.tripan.app.partner.service.PartnerCouponService;
import com.tripan.app.partner.service.PartnerInfoService;
import com.tripan.app.partner.service.PartnerReviewService;
import com.tripan.app.partner.service.PartnerRoomService;
import com.tripan.app.security.CustomUserDetails;

import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/partner")
@RequiredArgsConstructor
public class PartnerMainController {

    private final PartnerInfoService partnerInfoService;
    private final PartnerRoomService partnerRoomService;
    private final PartnerReviewService partnerReviewService;
    private final PartnerCouponService partnerCouponService;

    @GetMapping("/main")
    public String main(
            @RequestParam(value = "tab", defaultValue = "dashboard") String tab,
            @RequestParam(value = "partnerId", required = false) Long requestedPartnerId,
            @RequestParam Map<String, Object> searchParams,
            
            @RequestParam(value = "startDate", required = false) String startDate,
            @RequestParam(value = "endDate", required = false) String endDate,
            @RequestParam(value = "roomId", required = false) String searchRoomId,
            @RequestParam(value = "status", required = false) String searchStatus,
            @RequestParam(value = "keyword", required = false) String keyword,
            @RequestParam(value = "rating", required = false) String rating,
            
            @AuthenticationPrincipal CustomUserDetails userDetails,
            jakarta.servlet.http.HttpSession session,
            Model model) {

        Long memberId = userDetails.getMember().getMemberId();
        
        List<PartnerInfoDto> partnerList = partnerInfoService.getPartnerListByMemberId(memberId);
        
        if (partnerList == null || partnerList.isEmpty()) {
            model.addAttribute("activeTab", "new_apply");
            return "partner/main";
        }
        
        model.addAttribute("partnerList", partnerList);

        Long currentPartnerId = requestedPartnerId != null ? requestedPartnerId : (Long) session.getAttribute("currentPartnerId");
        
        final Long finalTargetId = currentPartnerId;
        boolean isValid = currentPartnerId != null && partnerList.stream().anyMatch(p -> p.getPartnerId().equals(finalTargetId));
        
        if (!isValid) {
            currentPartnerId = partnerList.get(0).getPartnerId(); 
        }
        
        final Long safeTargetId = currentPartnerId;
        PartnerInfoDto currentPartner = partnerList.stream()
                .filter(p -> p.getPartnerId().equals(safeTargetId))
                .findFirst().orElse(partnerList.get(0));
        
        String status = currentPartner.getStatus(); 
        
        if ("0".equals(status) || "PENDING".equals(status) || "REJECTED".equals(status)) {
            return "redirect:/partner/apply?partnerId=" + currentPartner.getPartnerId();
        }

        if ("SUSPENDED".equals(status) || "BLOCKED".equals(status)) {
            model.addAttribute("title", "접근 제한");
            model.addAttribute("message", "해당 파트너사가 정지 또는 차단 상태입니다.<br>문의: support@tripan.com");
            return "error/error2";
        }
        
        session.setAttribute("currentPartnerId", currentPartnerId);
        
        model.addAttribute("currentPartner", currentPartner);
        model.addAttribute("partnerInfo", currentPartner);
        model.addAttribute("activeTab", tab);

        Long placeId = partnerInfoService.getPlaceIdByPartnerId(currentPartnerId);
        
        if (placeId != null) {
            AccommodationDetailDto accommodation = partnerRoomService.getAccommodationDetailForPartner(placeId, memberId);
            model.addAttribute("accommodation", accommodation);
            
            List<PartnerRoomDto> roomList = partnerRoomService.getRoomsByPlaceId(placeId);
            model.addAttribute("roomList", roomList);
        }
        
        if ("booking".equals(tab)) {
            searchParams.put("placeId", placeId); 
            List<Map<String, Object>> bookingList = partnerRoomService.getBookingListForPartner(searchParams);
            model.addAttribute("bookingList", bookingList);
        }
        
        if ("review".equals(tab)) {
            List<PartnerReviewDto> reviewList = partnerReviewService.getReviewList(
                    placeId, startDate, endDate, searchRoomId, rating, keyword);
            model.addAttribute("reviewList", reviewList);
        }
        
        if ("coupon".equals(tab)) {
            searchParams.put("partnerId", currentPartnerId);
            
            Map<String, Object> kpiStats = partnerCouponService.getCouponKpiStats(currentPartnerId);
            model.addAttribute("kpiStats", kpiStats);
            
            List<PartnerCouponDto> couponList = partnerCouponService.getCouponList(searchParams);
            model.addAttribute("couponList", couponList);
            
            if (placeId != null && model.getAttribute("accommodation") != null) {
                model.addAttribute("partnerPlaceList", List.of(model.getAttribute("accommodation")));
            }
        }
        
        return "partner/main";
    }

    @ResponseBody
    @PostMapping("/api/info/update")
    public ResponseEntity<?> updatePartnerInfo(
            @ModelAttribute PartnerInfoDto dto, // 
            jakarta.servlet.http.HttpSession session) {
        try {
            Long currentPartnerId = (Long) session.getAttribute("currentPartnerId");
            dto.setPartnerId(currentPartnerId);
            
            Long currentPlaceId = partnerInfoService.getPlaceIdByPartnerId(currentPartnerId);
            dto.setPlaceId(currentPlaceId);
            
            partnerInfoService.updatePartnerInfo(dto);
            return ResponseEntity.ok(Map.of("message", "success"));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().body(Map.of("message", "fail"));
        }
    }
    
    @ResponseBody
    @PostMapping("/api/room/save")
    public ResponseEntity<?> saveRoom(
            @ModelAttribute PartnerRoomDto dto, 
            @RequestParam(value = "images", required = false) List<MultipartFile> images,
            @AuthenticationPrincipal CustomUserDetails userDetails,
            jakarta.servlet.http.HttpSession session) { // 
        try {
            Long currentPartnerId = (Long) session.getAttribute("currentPartnerId");
            Long placeId = partnerInfoService.getPlaceIdByPartnerId(currentPartnerId);
            dto.setPlaceId(placeId);
            
            if (dto.getRoomId() == null || dto.getRoomId().trim().isEmpty()) {
                partnerRoomService.registerNewRoom(dto, images);
            } else {
                partnerRoomService.updateRoomInfo(dto, images);
            }

            return ResponseEntity.ok(Map.of("message", "success"));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().body(Map.of("message", "fail"));
        }
    }
    
    @ResponseBody
    @PostMapping("/api/facility/update")
    public ResponseEntity<?> updateFacility(
            @RequestBody Map<String, Object> params, 
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        try {
            return ResponseEntity.ok(Map.of("message", "success"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("message", "fail"));
        }
    }
    
    // 객실 삭제 컨트롤러
    @ResponseBody
    @PostMapping("/api/room/delete")
    public ResponseEntity<?> deleteRoom(@RequestParam("roomId") String roomId) {
        try {
            partnerRoomService.deleteRoom(roomId);
            return ResponseEntity.ok(Map.of("message", "success"));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().body(Map.of("message", "fail"));
        }
    }
    
    @ResponseBody
    @GetMapping("/api/calendar/events")
    public ResponseEntity<List<Map<String, Object>>> getCalendarEvents(
            @RequestParam("start") String start, 
            @RequestParam("end") String end,     
            jakarta.servlet.http.HttpSession session) {
        
        try {
            Long currentPartnerId = (Long) session.getAttribute("currentPartnerId");
            Long placeId = partnerInfoService.getPlaceIdByPartnerId(currentPartnerId);
            
            List<Map<String, Object>> eventList = partnerRoomService.getCalendarEvents(placeId, start, end);

            return ResponseEntity.ok(eventList);
            
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().body(new ArrayList<>());
        }
    }

    @ResponseBody
    @PostMapping("/api/booking/cancel")
    public ResponseEntity<?> cancelBookingByPartner(
            @RequestBody Map<String, Object> payload,
            jakarta.servlet.http.HttpSession session) {
            
        try {
            Long currentPartnerId = (Long) session.getAttribute("currentPartnerId");
            if (currentPartnerId == null) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "파트너 권한이 없습니다."));
            }
            
            Long reservationId = Long.valueOf(payload.get("reservationId").toString());
            String reason = (String) payload.get("reason");

            partnerRoomService.cancelReservationByPartner(reservationId, currentPartnerId, reason);

            return ResponseEntity.ok(Map.of("message", "success"));
            
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().body(Map.of("message", e.getMessage()));
        }
    }
    
    @ResponseBody
    @PostMapping("/api/review/delete")
    public ResponseEntity<?> deleteReview(@RequestBody Map<String, Long> payload) {
        try {
            Long reviewId = payload.get("reviewId"); 
            partnerReviewService.deleteReview(reviewId);
            return ResponseEntity.ok(Map.of("message", "success"));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().body(Map.of("message", "fail"));
        }
    }
    
    @ResponseBody
    @PostMapping("/api/coupon/save")
    public ResponseEntity<?> saveCoupon(
            @RequestBody PartnerCouponDto dto, 
            @RequestParam("placeId") String placeId, 
            jakarta.servlet.http.HttpSession session) {
        try {
            Long currentPartnerId = (Long) session.getAttribute("currentPartnerId");
            if (currentPartnerId == null) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "권한 없음"));
            }
            
            partnerCouponService.createPartnerCoupon(dto, currentPartnerId, placeId);
            
            return ResponseEntity.ok(Map.of("message", "success"));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().body(Map.of("message", "fail"));
        }
    }
    
    @ResponseBody
    @PostMapping("/api/coupon/stop")
    public ResponseEntity<?> stopCoupon(
            @RequestBody Map<String, Long> payload,
            jakarta.servlet.http.HttpSession session) {
        try {
            Long currentPartnerId = (Long) session.getAttribute("currentPartnerId");
            if (currentPartnerId == null) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "권한 없음"));
            }
            
            Long couponId = payload.get("couponId");
            partnerCouponService.stopCoupon(couponId);
            
            return ResponseEntity.ok(Map.of("message", "success"));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().body(Map.of("message", "fail"));
        }
    }
    
}