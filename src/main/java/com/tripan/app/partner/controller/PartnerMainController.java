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
import com.tripan.app.partner.domain.dto.PartnerRoomDto;
import com.tripan.app.partner.service.PartnerCouponService;
import com.tripan.app.partner.service.PartnerDashboardService;
import com.tripan.app.partner.service.PartnerInfoService;
import com.tripan.app.partner.service.PartnerReviewService;
import com.tripan.app.partner.service.PartnerRoomService;
import com.tripan.app.partner.service.PartnerSettlementServiceforPartner;
import com.tripan.app.partner.service.PartnerStatsService;
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
    private final PartnerSettlementServiceforPartner partnerSettlementServiceforPartner;
    private final PartnerStatsService partnerStatsService;
    private final PartnerDashboardService partnerDashboardService; 

    @GetMapping("/main")
    public String main(
            @RequestParam(value = "tab", defaultValue = "dashboard") String tab,
            @RequestParam(value = "partnerId", required = false) Long requestedPartnerId,
            
            @RequestParam Map<String, Object> searchParams,
            
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
        
        String partnerStatus = currentPartner.getStatus(); 
        
        if ("0".equals(partnerStatus) || "PENDING".equals(partnerStatus) || "REJECTED".equals(partnerStatus)) {
            return "redirect:/partner/apply?partnerId=" + currentPartner.getPartnerId();
        }

        if ("SUSPENDED".equals(partnerStatus) || "BLOCKED".equals(partnerStatus)) {
            model.addAttribute("title", "접근 제한");
            model.addAttribute("message", "해당 파트너사가 정지 또는 차단 상태입니다.<br>문의: support@tripan.com");
            return "error/error2";
        }
 
        Long placeId = partnerInfoService.getPlaceIdByPartnerId(currentPartnerId);
        
        if (placeId != null) {
            AccommodationDetailDto accommodation = partnerRoomService.getAccommodationDetailForPartner(placeId, memberId);
            model.addAttribute("accommodation", accommodation);
            
            List<PartnerRoomDto> roomList = partnerRoomService.getRoomsByPlaceId(placeId);
            model.addAttribute("roomList", roomList);
        }
        
        if ("room".equals(tab)) {
            int page = searchParams.containsKey("page") ? Integer.parseInt(searchParams.get("page").toString()) : 1;
            
            Map<String, Object> pagingResult = partnerRoomService.getPagedRoomList(placeId, page);
            model.addAttribute("pagedRoomList", pagingResult.get("roomList"));
            model.addAttribute("roomTotalPages", pagingResult.get("totalPages"));
            model.addAttribute("currentPage", page);
        }
        
        if ("dashboard".equals(tab)) {
            Map<String, Object> dashData = partnerDashboardService.getDashboardData(currentPartnerId);
            model.addAttribute("dashData", dashData);
        }
         
        if ("booking".equals(tab)) {
            searchParams.put("placeId", placeId); 
            
            int page = searchParams.containsKey("page") && searchParams.get("page") != null && !searchParams.get("page").toString().isEmpty() 
                       ? Integer.parseInt(searchParams.get("page").toString()) : 1;
                       
            int limit = searchParams.containsKey("limit") && searchParams.get("limit") != null && !searchParams.get("limit").toString().isEmpty() 
                        ? Integer.parseInt(searchParams.get("limit").toString()) : 10;
            
            searchParams.put("page", page);
            searchParams.put("limit", limit);
            
            Map<String, Object> pagingResult = partnerRoomService.getPagedBookingList(searchParams);
            
            model.addAttribute("bookingList", pagingResult.get("bookingList"));
            model.addAttribute("totalPages", pagingResult.get("totalPages")); 
            model.addAttribute("currentPage", page);
        }
        
        if ("review".equals(tab)) {
            searchParams.put("placeId", placeId);
            
            int page = searchParams.containsKey("page") && searchParams.get("page") != null && !searchParams.get("page").toString().isEmpty() 
                       ? Integer.parseInt(searchParams.get("page").toString()) : 1;
                       
            int limit = searchParams.containsKey("limit") && searchParams.get("limit") != null && !searchParams.get("limit").toString().isEmpty() 
                        ? Integer.parseInt(searchParams.get("limit").toString()) : 10;
            
            searchParams.put("page", page);
            searchParams.put("limit", limit);
            
            Map<String, Object> pagingResult = partnerReviewService.getPagedReviewList(searchParams);
            
            model.addAttribute("reviewList", pagingResult.get("reviewList"));
            model.addAttribute("totalPages", pagingResult.get("totalPages"));
            model.addAttribute("currentPage", page);
        }
        
        if ("coupon".equals(tab)) {
            searchParams.put("partnerId", currentPartnerId);
            
            Map<String, Object> kpiStats = partnerCouponService.getCouponKpiStats(currentPartnerId);
            model.addAttribute("kpiStats", kpiStats);
            
            int page = searchParams.containsKey("page") && searchParams.get("page") != null && !searchParams.get("page").toString().isEmpty() 
                       ? Integer.parseInt(searchParams.get("page").toString()) : 1;
            int limit = searchParams.containsKey("limit") && searchParams.get("limit") != null && !searchParams.get("limit").toString().isEmpty() 
                        ? Integer.parseInt(searchParams.get("limit").toString()) : 10;
            
            searchParams.put("page", page);
            searchParams.put("limit", limit);
            
            Map<String, Object> pagingResult = partnerCouponService.getPagedCouponList(searchParams);
            
            model.addAttribute("couponList", pagingResult.get("couponList"));
            model.addAttribute("totalPages", pagingResult.get("totalPages"));
            model.addAttribute("currentPage", page);
            
            if (placeId != null && model.getAttribute("accommodation") != null) {
                model.addAttribute("partnerPlaceList", List.of(model.getAttribute("accommodation")));
            }
        }
        
        if ("settle".equals(tab)) {
            String settleMonth = (String) searchParams.get("settleMonth");
            String status = (String) searchParams.get("status");
            
            Map<String, Object> expectedSettlement = partnerSettlementServiceforPartner.getExpectedSettlement(currentPartnerId);
            model.addAttribute("expectedSettlement", expectedSettlement);

            List<Map<String, Object>> settlementList = partnerSettlementServiceforPartner.getSettlementList(currentPartnerId, settleMonth, status);
            model.addAttribute("settlementList", settlementList);
        }
        
        session.setAttribute("currentPartnerId", currentPartnerId);
        
        model.addAttribute("currentPartner", currentPartner);
        model.addAttribute("partnerInfo", currentPartner);
        model.addAttribute("activeTab", tab);
        
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
            jakarta.servlet.http.HttpSession session) { 
        try {
            Long currentPartnerId = (Long) session.getAttribute("currentPartnerId");
            Long placeId = partnerInfoService.getPlaceIdByPartnerId(currentPartnerId);
            dto.setPlaceId(placeId); 
            
            if (dto.getRoomId() == null || dto.getRoomId().trim().isEmpty()) {
                partnerRoomService.registerNewRoom(dto, images);
            } else {
                List<PartnerRoomDto> myRooms = partnerRoomService.getRoomsByPlaceId(placeId);
                boolean isMyRoom = myRooms.stream().anyMatch(r -> r.getRoomId().equals(dto.getRoomId()));
                
                if (!isMyRoom) {
                    return ResponseEntity.status(HttpStatus.FORBIDDEN).body(Map.of("message", "해당 객실을 수정할 권한이 없습니다."));
                }
                
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
    public ResponseEntity<?> deleteRoom(
            @RequestParam("roomId") String roomId, 
            jakarta.servlet.http.HttpSession session) { 
        try {
            Long currentPartnerId = (Long) session.getAttribute("currentPartnerId");
            if (currentPartnerId == null) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "로그인이 필요합니다."));
            }

            Long placeId = partnerInfoService.getPlaceIdByPartnerId(currentPartnerId);

            List<PartnerRoomDto> myRooms = partnerRoomService.getRoomsByPlaceId(placeId);
            boolean isMyRoom = myRooms.stream().anyMatch(r -> r.getRoomId().equals(roomId));
            
            if (!isMyRoom) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN).body(Map.of("message", "해당 객실을 삭제할 권한이 없습니다."));
            }

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
    
    @ResponseBody
    @GetMapping("/api/settlement/detail")
    public ResponseEntity<?> getSettlementDetail(
            @RequestParam("month") String month,
            jakarta.servlet.http.HttpSession session) {
        try {
            Long currentPartnerId = (Long) session.getAttribute("currentPartnerId");
            if (currentPartnerId == null) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "권한 없음"));
            }
            
            List<Map<String, Object>> detailList = partnerSettlementServiceforPartner.getSettlementDetailList(currentPartnerId, month);
            
            return ResponseEntity.ok(detailList);
            
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().body(Map.of("message", "fail"));
        }
    }
    
 // 🌟 [엑셀 다운로드 API] 정산 내역 엑셀 변환
    @GetMapping("/api/settlement/excel")
    public void downloadSettlementExcel(
            @RequestParam(value = "settleMonth", required = false) String settleMonth,
            @RequestParam(value = "status", required = false) String status,
            jakarta.servlet.http.HttpSession session,
            jakarta.servlet.http.HttpServletResponse response) throws java.io.IOException {

        Long currentPartnerId = (Long) session.getAttribute("currentPartnerId");
        if (currentPartnerId == null) return;

        java.util.List<java.util.Map<String, Object>> list = partnerSettlementServiceforPartner.getSettlementList(currentPartnerId, settleMonth, status);

        org.apache.poi.ss.usermodel.Workbook wb = new org.apache.poi.xssf.usermodel.XSSFWorkbook();
        org.apache.poi.ss.usermodel.Sheet sheet = wb.createSheet("정산내역");
        org.apache.poi.ss.usermodel.Row row = null;
        org.apache.poi.ss.usermodel.Cell cell = null;
        int rowNum = 0;

        org.apache.poi.ss.usermodel.CellStyle headerStyle = wb.createCellStyle();
        headerStyle.setFillForegroundColor(org.apache.poi.ss.usermodel.IndexedColors.GREY_25_PERCENT.getIndex());
        headerStyle.setFillPattern(org.apache.poi.ss.usermodel.FillPatternType.SOLID_FOREGROUND);
        
        org.apache.poi.ss.usermodel.Font font = wb.createFont();
        font.setBold(true);
        headerStyle.setFont(font);

        row = sheet.createRow(rowNum++);
        String[] headers = {"정산월", "총 결제 매출액", "수수료율(%)", "수수료액", "쿠폰 분담금", "최종 정산액", "상태"};
        for(int i=0; i<headers.length; i++) {
            cell = row.createCell(i);
            cell.setCellValue(headers[i]);
            cell.setCellStyle(headerStyle);
            sheet.setColumnWidth(i, 4000); // 열 너비 살짝 넓게
        }

        for (java.util.Map<String, Object> map : list) {
            row = sheet.createRow(rowNum++);
            row.createCell(0).setCellValue(String.valueOf(map.get("settlementMonth")));
            row.createCell(1).setCellValue(((Number) map.get("totalSales")).doubleValue());
            row.createCell(2).setCellValue(((Number) map.get("commissionRate")).doubleValue());
            row.createCell(3).setCellValue(((Number) map.get("commissionAmount")).doubleValue());
            row.createCell(4).setCellValue(((Number) map.get("partnerCouponAmount")).doubleValue());
            row.createCell(5).setCellValue(((Number) map.get("netAmount")).doubleValue());
            
            String statusStr = "COMPLETED".equals(map.get("status")) ? "지급 완료" : "정산 예정";
            row.createCell(6).setCellValue(statusStr);
        }

        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        
        String dateStr = java.time.LocalDate.now().format(java.time.format.DateTimeFormatter.ofPattern("yyyyMMdd"));
        String fileName = "Settlement_History_" + dateStr + ".xlsx";
        
        String encodedFileName = new String(fileName.getBytes("UTF-8"), "ISO-8859-1");
        response.setHeader("Content-Disposition", "attachment;filename=\"" + encodedFileName + "\"");

        wb.write(response.getOutputStream());
        wb.close();
    }   
    
    @ResponseBody
    @GetMapping("/api/stats/data")
    public ResponseEntity<?> getStatsData(
            @RequestParam("month") String month,
            jakarta.servlet.http.HttpSession session) {
        
        try {
            Long currentPartnerId = (Long) session.getAttribute("currentPartnerId");
            if (currentPartnerId == null) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "권한 없음"));
            }
            
            Map<String, Object> statsData = partnerStatsService.getStatsData(currentPartnerId, month);
            
            return ResponseEntity.ok(statsData);
            
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().body(Map.of("message", "fail"));
        }
    }
    
}