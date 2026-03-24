package com.tripan.app.partner.controller;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

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
import com.tripan.app.mapper.AccommodationMapper;
import com.tripan.app.partner.domain.dto.PartnerInfoDto;
import com.tripan.app.partner.domain.dto.PartnerRoomDto;
import com.tripan.app.partner.mapper.PartnerRoomMapper;
import com.tripan.app.partner.service.PartnerInfoService;
import com.tripan.app.partner.service.PartnerRoomService;
import com.tripan.app.security.CustomUserDetails;

import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/partner")
@RequiredArgsConstructor
public class PartnerMainController {

    private final PartnerInfoService partnerInfoService;
    private final PartnerRoomMapper partnerRoomMapper; 
    private final AccommodationMapper accommodationMapper;
    private final PartnerRoomService partnerRoomService; 

    @GetMapping("/main")
    public String main(
            @RequestParam(value = "tab", defaultValue = "dashboard") String tab,
            @RequestParam(value = "partnerId", required = false) Long requestedPartnerId,
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
            AccommodationDetailDto accommodation = accommodationMapper.selectAccommodationDetailForPartner(placeId, memberId);
            model.addAttribute("accommodation", accommodation);
            
            List<PartnerRoomDto> roomList = partnerRoomMapper.getRoomsByPlaceId(placeId);
            model.addAttribute("roomList", roomList);
        }
        
        if ("booking".equals(tab)) {
            List<Map<String, Object>> bookingList = partnerRoomMapper.selectBookingListForPartner(placeId);
            model.addAttribute("bookingList", bookingList);
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
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        try {
            Long placeId = partnerInfoService.getPlaceIdByMemberId(userDetails.getMember().getMemberId());
            dto.setPlaceId(placeId);
            
            partnerRoomService.registerNewRoom(dto, images);

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
}