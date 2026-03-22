package com.tripan.app.admin.mapper;

import com.tripan.app.admin.domain.dto.ReservationResponseDto;

import com.tripan.app.admin.domain.dto.CouponDto;
import com.tripan.app.admin.domain.dto.ReservationDto;
import com.tripan.app.admin.domain.dto.ReservationSearchDto;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface ReservationManageMapper {

    // 기존
    List<ReservationResponseDto> selectAllBookings();
    List<ReservationResponseDto> selectBookingsByMemberId(@Param("memberId") Long memberId);
    void updateBookingStatus(@Param("id") Long id, @Param("status") String status);

    // 관리자 메인
    List<ReservationDto> selectReservationList(ReservationSearchDto searchDto);
    long countReservationList(ReservationSearchDto searchDto);
    ReservationDto selectReservationKpi(ReservationSearchDto searchDto);
    ReservationDto selectReservationDetail(@Param("reservationId") Long reservationId);

    // 쿠폰 사용 내역 (예약별, 복수 가능)
    List<CouponDto.UsageItem> selectCouponUsageByReservationId(@Param("reservationId") Long reservationId);

    // 상태 변경
    void updateReservationStatus(@Param("reservationId") Long reservationId, @Param("status") String status);
}