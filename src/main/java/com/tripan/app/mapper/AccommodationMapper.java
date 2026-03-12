package com.tripan.app.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.tripan.app.domain.dto.AccommodationDetailDto;
import com.tripan.app.domain.dto.AccommodationDto;
import com.tripan.app.domain.dto.AdSearchConditionDto;
import com.tripan.app.domain.dto.ReservationRequestDto;
import com.tripan.app.domain.dto.RoomDto;

@Mapper
public interface AccommodationMapper {
	public List<AccommodationDto> selectAccommodationList(AdSearchConditionDto condition);
	
	AccommodationDetailDto selectAccommodationDetail(@Param("placeId") Long placeId, @Param("memberId") Long memberId);
    
    public List<String> selectAccommodationImages(Long placeId);
    
    public List<RoomDto> selectRoomsByPlaceId(Long placeId);
    
    public RoomDto findRoomById(String roomId);
    
    // 동시성 문제 해결 관련
    void deleteExpiredLocks();
    String getRoomLockSession(@Param("roomId") String roomId, @Param("checkin") String checkin);
    void insertRoomLock(@Param("roomId") String roomId, @Param("checkin") String checkin, @Param("sessionId") String sessionId);
    void updateLockTime(@Param("roomId") String roomId, @Param("checkin") String checkin);
    void deleteRoomLock(@Param("roomId") String roomId, @Param("checkin") String checkin, @Param("sessionId") String sessionId);
    
    // 예약, 결제 관련
    void insertOrder(ReservationRequestDto dto);
    void insertOrderDetail(ReservationRequestDto dto);
    void insertReservation(ReservationRequestDto dto);
    void insertPayment(ReservationRequestDto dto);
    
    
    // 북마크(찜) 관련
    int checkBookmark(@Param("placeId") Long placeId, @Param("memberId") Long memberId);
    void insertBookmark(@Param("placeId") Long placeId, @Param("memberId") Long memberId);
    void deleteBookmark(@Param("placeId") Long placeId, @Param("memberId") Long memberId);
}
