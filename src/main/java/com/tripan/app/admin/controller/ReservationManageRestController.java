package com.tripan.app.admin.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.tripan.app.admin.domain.dto.ReservationDto;
import com.tripan.app.admin.domain.dto.ReservationResponseDto;
import com.tripan.app.admin.domain.dto.ReservationSearchDto;
import com.tripan.app.admin.service.ReservationManageService;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/admin/reservations")
@RequiredArgsConstructor
public class ReservationManageRestController {

    private final ReservationManageService reservationManageService;

    /** 전체 예약 목록 (심플) */
    @GetMapping("/all")
    public ResponseEntity<List<ReservationResponseDto>> getAllBookings() {
        return ResponseEntity.ok(reservationManageService.getAllBookings());
    }
 
    /** 회원별 예약 목록 */
    @GetMapping("/member/{memberId}")
    public ResponseEntity<List<ReservationResponseDto>> getBookingsByMember(
            @PathVariable Long memberId) {
        return ResponseEntity.ok(reservationManageService.getBookingsByMember(memberId));
    }
 
    /** 예약 상태 변경 (기존) */
    @PutMapping("/{id}/status")
    public ResponseEntity<Map<String, Object>> changeBookingStatus(
            @PathVariable("id") Long id,
            @RequestBody Map<String, String> body) {
        reservationManageService.changeBookingStatus(id, body.get("status"));
        return ResponseEntity.ok(Map.of("message", "예약 상태가 변경되었습니다."));
    }
 
    /** 예약 목록 조회 (검색/필터/페이징) */
    @GetMapping
    public ResponseEntity<Map<String, Object>> getReservationList(ReservationSearchDto searchDto) {
        return ResponseEntity.ok(reservationManageService.getReservationList(searchDto));
    }
 
    /** KPI 집계 */
    @GetMapping("/kpi")
    public ResponseEntity<Map<String, Object>> getReservationKpi(ReservationSearchDto searchDto) {
        return ResponseEntity.ok(reservationManageService.getReservationKpi(searchDto));
    }
 
    /** 예약 상세 조회 */
    @GetMapping("/{reservationId}")
    public ResponseEntity<ReservationDto> getReservationDetail(
            @PathVariable("reservationId") Long reservationId) {
        return ResponseEntity.ok(reservationManageService.getReservationDetail(reservationId));
    }
 
    /** 예약 상태 변경  */
    @PutMapping("/{reservationId}/statusByResId")
    public ResponseEntity<Map<String, Object>> updateReservationStatus(
            @PathVariable("reservationId") Long reservationId,
            @RequestBody Map<String, String> body) {
        reservationManageService.updateReservationStatus(reservationId, body.get("status"));
        return ResponseEntity.ok(Map.of("message", "예약 상태가 변경되었습니다."));
    }
}