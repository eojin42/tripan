package com.tripan.app.admin.service;

import com.tripan.app.admin.domain.dto.CouponDto;
import com.tripan.app.admin.domain.dto.ReservationDto;
import com.tripan.app.admin.domain.dto.ReservationResponseDto;
import com.tripan.app.admin.domain.dto.ReservationSearchDto;
import com.tripan.app.admin.domain.entity.Booking;
import com.tripan.app.admin.mapper.ReservationManageMapper;
import com.tripan.app.admin.repository.BookingManageRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true) 
public class ReservationManageServiceImpl implements ReservationManageService {

    private final ReservationManageMapper reservationManageMapper;
    private final BookingManageRepository bookingRepository;


    @Override
    public List<ReservationResponseDto> getAllBookings() {
        log.info("Super Admin - 모든 예약 내역 조회를 시작합니다.");
        return reservationManageMapper.selectAllBookings();
    }

    @Override
    public List<ReservationResponseDto> getBookingsByMember(Long memberId) {
        log.info("회원 ID {}의 예약 내역 조회를 시작합니다.", memberId);
        return reservationManageMapper.selectBookingsByMemberId(memberId);
    }

    @Override
    @Transactional 
    public void changeBookingStatus(Long id, String newStatus) {
        log.info("예약 ID {}의 상태를 {}로 변경합니다.", id, newStatus);
        
        Booking booking = bookingRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("해당 예약 정보를 찾을 수 없습니다. ID: " + id));
        
        booking.setStatus(newStatus);
        
        if (newStatus == "CANCELED") {
            log.info("예약 번호 {}의 취소 처리가 기록되었습니다.", booking.getResId());
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public Map<String, Object> getReservationList(ReservationSearchDto searchDto) {
        List<ReservationDto> list = reservationManageMapper.selectReservationList(searchDto);
        long totalCount          = reservationManageMapper.countReservationList(searchDto);
        int  totalPages          = (int) Math.ceil((double) totalCount / searchDto.getSize());
 
        Map<String, Object> result = new HashMap<>();
        result.put("list",       list);
        result.put("page",       searchDto.getPage());
        result.put("totalPages", totalPages);
        result.put("totalCount", totalCount);
        return result;
    }
 
    @Override
    @Transactional(readOnly = true)
    public Map<String, Object> getReservationKpi(ReservationSearchDto searchDto) {
        ReservationDto kpi = reservationManageMapper.selectReservationKpi(searchDto);
 
        Map<String, Object> result = new HashMap<>();
        result.put("totalCount",     kpi.getTotalCount());
        result.put("reservedCount",  kpi.getReservedCount());
        result.put("usedCount",      kpi.getUsedCount());
        result.put("cancelledCount", kpi.getCancelledCount());
        return result;
    }
 
    @Override
    @Transactional(readOnly = true)
    public ReservationDto getReservationDetail(Long reservationId) {
        ReservationDto detail                  = reservationManageMapper.selectReservationDetail(reservationId);
        List<CouponDto.UsageItem> coupons      = reservationManageMapper.selectCouponUsageByReservationId(reservationId);
 
        Map<String, Object> result = new HashMap<>();
        result.put("detail",  detail);
        result.put("coupons", coupons);
        return detail;
    }
 
    @Override
    @Transactional
    public void updateReservationStatus(Long reservationId, String status) {
        reservationManageMapper.updateReservationStatus(reservationId, status);
    }
}