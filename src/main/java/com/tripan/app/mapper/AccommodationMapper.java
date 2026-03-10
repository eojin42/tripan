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
	
	public AccommodationDetailDto selectAccommodationDetail(Long placeId);
    
    public List<String> selectAccommodationImages(Long placeId);
    
    public List<RoomDto> selectRoomsByPlaceId(Long placeId);
    
    public RoomDto findRoomById(String roomId);
    
    
    void deleteExpiredLocks();
    String getRoomLockSession(@Param("roomId") String roomId, @Param("checkin") String checkin);
    void insertRoomLock(@Param("roomId") String roomId, @Param("checkin") String checkin, @Param("sessionId") String sessionId);
    void updateLockTime(@Param("roomId") String roomId, @Param("checkin") String checkin);
    void deleteRoomLock(@Param("roomId") String roomId, @Param("checkin") String checkin, @Param("sessionId") String sessionId);
    
    
    void insertOrder(ReservationRequestDto dto);
    void insertOrderDetail(ReservationRequestDto dto);
    void insertReservation(ReservationRequestDto dto);
    void insertPayment(ReservationRequestDto dto);
}
