package com.tripan.app.admin.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.tripan.app.admin.domain.dto.BookingResponseDto;

@Mapper
public interface BookingManageMapper {

    List<BookingResponseDto> selectMemberBookings(@Param("memberId") Long memberId);
    List<BookingResponseDto> selectAllBookings();
    BookingResponseDto selectBookingDetail(Long id);
    List<BookingResponseDto> selectBookingsByMemberId(Long memberId);
}
