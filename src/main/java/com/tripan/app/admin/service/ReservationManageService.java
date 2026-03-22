package com.tripan.app.admin.service;

import java.util.List;
import java.util.Map;

import com.tripan.app.admin.domain.dto.ReservationDto;
import com.tripan.app.admin.domain.dto.ReservationResponseDto;
import com.tripan.app.admin.domain.dto.ReservationSearchDto;

public interface ReservationManageService {

    List<ReservationResponseDto> getAllBookings();
    List<ReservationResponseDto> getBookingsByMember(Long memberId);
    void changeBookingStatus(Long id, String newStatus);
    
    Map<String, Object> getReservationList(ReservationSearchDto searchDto);
    Map<String, Object> getReservationKpi(ReservationSearchDto searchDto);
    ReservationDto getReservationDetail(Long reservationId);
    void updateReservationStatus(Long reservationId, String status);
    
}