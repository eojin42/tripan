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
    public String main(
            @RequestParam(value = "tab", defaultValue = "dashboard") String tab,
            @RequestParam(value = "partnerId", required = false) Long requestedPartnerId,
            @AuthenticationPrincipal CustomUserDetails userDetails,
            jakarta.servlet.http.HttpSession session,
            Model model) {

        Long memberId = userDetails.getMember().getMemberId();
        
        List<PartnerInfoDto> partnerList = partnerInfoService.getPartnerListByMemberId(memberId);
        
        // 등록된 숙소가 없으면 신규 입점 화면으로 강제 이동
        if (partnerList == null || partnerList.isEmpty()) {
            model.addAttribute("activeTab", "new_apply");
            return "partner/main";
        }
        
        model.addAttribute("partnerList", partnerList);

        // 현재 파트너 ID 결정 및 세션 검증
        Long currentPartnerId = requestedPartnerId != null ? requestedPartnerId : (Long) session.getAttribute("currentPartnerId");
        
        final Long finalTargetId = currentPartnerId;
        boolean isValid = currentPartnerId != null && partnerList.stream().anyMatch(p -> p.getPartnerId().equals(finalTargetId));
        
        if (!isValid) {
            currentPartnerId = partnerList.get(0).getPartnerId(); 
        }
        
        PartnerInfoDto info = partnerInfoService.getPartnerInfo(memberId);
        if (info != null && ("SUSPENDED".equals(info.getStatus()) || "BLOCKED".equals(info.getStatus()))) {
            model.addAttribute("title", "접근 제한");
            model.addAttribute("message", "파트너사가 정지 또는 차단 상태입니다.<br>문의: support@tripan.com");
            return "error/error2";
        }
        
        session.setAttribute("currentPartnerId", currentPartnerId);
        
        // 화면에 뿌려줄 파트너 정보 찾기
        final Long safeTargetId = currentPartnerId;
        PartnerInfoDto currentPartner = partnerList.stream()
                .filter(p -> p.getPartnerId().equals(safeTargetId))
                .findFirst().orElse(partnerList.get(0));

        // 기존 JSP와의 호환성을 위해 두 개의 이름으로 담아줌
        model.addAttribute("currentPartner", currentPartner);
        model.addAttribute("partnerInfo", currentPartner);
        model.addAttribute("activeTab", tab);

        // 선택된 숙소(Partner)와 연결된 장소(Place) 및 객실(Room) 정보 조회
        Long placeId = partnerInfoService.getPlaceIdByPartnerId(currentPartnerId);
        
        if (placeId != null) {
            AccommodationDetailDto accommodation = accommodationMapper.selectAccommodationDetailForPartner(placeId, memberId);
            model.addAttribute("accommodation", accommodation);
            
            List<PartnerRoomDto> roomList = partnerRoomMapper.getRoomsByPlaceId(placeId);
            model.addAttribute("roomList", roomList);
        }

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