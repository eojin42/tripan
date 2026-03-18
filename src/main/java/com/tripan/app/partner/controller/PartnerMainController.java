package com.tripan.app.partner.controller;

import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
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
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.tripan.app.domain.dto.AccommodationDetailDto;
import com.tripan.app.mapper.AccommodationMapper;
import com.tripan.app.partner.domain.dto.PartnerInfoDto;
import com.tripan.app.partner.domain.dto.PartnerRoomDto;
import com.tripan.app.partner.mapper.PartnerRoomMapper;
import com.tripan.app.partner.service.PartnerInfoService;
import com.tripan.app.security.CustomUserDetails;

import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/partner")
@RequiredArgsConstructor
public class PartnerMainController {

    private final PartnerInfoService partnerInfoService;
    private final PartnerRoomMapper partnerRoomMapper; 
    private final AccommodationMapper accommodationMapper;

    @GetMapping("/main")
    public String partnerMain(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @RequestParam(value = "tab", defaultValue = "dashboard") String tab, 
            RedirectAttributes rttr,
            Model model) {

        if (userDetails == null) return "redirect:/partner/login";
        if (!userDetails.getAuthorities().contains(new SimpleGrantedAuthority("ROLE_PARTNER"))) return "redirect:/partner/apply";

        Long memberId = userDetails.getMember().getMemberId();

        if ("info".equals(tab)) {
            PartnerInfoDto partnerInfo = partnerInfoService.getPartnerInfo(memberId);
            model.addAttribute("partnerInfo", partnerInfo);
        }

        if ("room".equals(tab)) {
            List<PartnerRoomDto> myRooms = partnerRoomMapper.getRoomListByMemberId(memberId);
            model.addAttribute("roomList", myRooms);
        }

        if ("facility".equals(tab)) {
            Long placeId = partnerInfoService.getPlaceIdByMemberId(memberId);
            
            AccommodationDetailDto facilityData = accommodationMapper.selectAccommodationDetailForPartner(placeId, null);
            
            model.addAttribute("accommodation", facilityData);
            model.addAttribute("facility", facilityData);
        }

        model.addAttribute("activeTab", tab);
        return "partner/main"; 
    }

    @ResponseBody
    @PostMapping("/api/info/update")
    public ResponseEntity<?> updatePartnerInfo(
            @RequestBody PartnerInfoDto dto,
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        try {
            PartnerInfoDto myInfo = partnerInfoService.getPartnerInfo(userDetails.getMember().getMemberId());
            dto.setPartnerId(myInfo.getPartnerId()); 
            
            partnerInfoService.updatePartnerInfo(dto);
            return ResponseEntity.ok(Map.of("message", "success"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("message", "fail"));
        }
    }
    
    @ResponseBody
    @PostMapping("/api/room/save")
    public ResponseEntity<?> saveRoom(
            @ModelAttribute PartnerRoomDto dto, 
            @RequestParam("images") List<MultipartFile> images,
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        try {
            Long placeId = partnerInfoService.getPlaceIdByMemberId(userDetails.getMember().getMemberId());
            dto.setPlaceId(placeId);
            
            dto.setRoomId("R-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase());
            dto.setRfId("RF-DEFAULT");

            partnerRoomMapper.insertRoom(dto);

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
            // TODO: Service 호출해서 accommodation & accommodation_facility 테이블 동시 업데이트!
            return ResponseEntity.ok(Map.of("message", "success"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("message", "fail"));
        }
    }
    
}