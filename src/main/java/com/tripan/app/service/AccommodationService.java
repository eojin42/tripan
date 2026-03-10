package com.tripan.app.service;

import java.util.List;

import com.tripan.app.domain.dto.AccommodationDetailDto;
import com.tripan.app.domain.dto.AccommodationDto;
import com.tripan.app.domain.dto.AdSearchConditionDto;
import com.tripan.app.domain.dto.ReservationRequestDto;
import com.tripan.app.domain.dto.RoomDto;

public interface AccommodationService {
	public List<AccommodationDto> searchAccommodations(AdSearchConditionDto condition);
	
	public AccommodationDetailDto getAccommodationDetail(Long placeId);
	
	public RoomDto findRoomById(String roomId);
	
	
	public boolean acquireLock(String roomId, String checkin, String sessionId);
    public void releaseLock(String roomId, String checkin, String sessionId);
    
    
    public void processReservation(ReservationRequestDto dto);
}
