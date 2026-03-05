package com.tripan.app.admin.service;

import com.tripan.app.admin.domain.dto.BookingResponseDto;
import java.util.List;

public interface BookingManageService {

    List<BookingResponseDto> getAllBookings();
    List<BookingResponseDto> getBookingsByMember(Long memberId);
    void changeBookingStatus(Long id, Integer newStatus);
}