package com.tripan.app.admin.service;

import com.tripan.app.admin.domain.dto.BookingResponseDto;
import com.tripan.app.admin.domain.entity.Booking;
import com.tripan.app.admin.mapper.BookingManageMapper;
import com.tripan.app.admin.repository.BookingManegeRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true) 
public class BookingManageServiceImpl implements BookingManageService {

    private final BookingManageMapper bookingMapper;
    private final BookingManegeRepository bookingRepository;


    @Override
    public List<BookingResponseDto> getAllBookings() {
        log.info("Super Admin - 모든 예약 내역 조회를 시작합니다.");
        return bookingMapper.selectAllBookings();
    }

    @Override
    public List<BookingResponseDto> getBookingsByMember(Long memberId) {
        log.info("회원 ID {}의 예약 내역 조회를 시작합니다.", memberId);
        return bookingMapper.selectMemberBookings(memberId);
    }

    @Override
    @Transactional 
    public void changeBookingStatus(Long id, Integer newStatus) {
        log.info("예약 ID {}의 상태를 {}로 변경합니다.", id, newStatus);
        
        Booking booking = bookingRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("해당 예약 정보를 찾을 수 없습니다. ID: " + id));
        
        booking.setStatus(newStatus);
        
        if (newStatus == 3) {
            log.info("예약 번호 {}의 취소 처리가 기록되었습니다.", booking.getResId());
        }
    }
}