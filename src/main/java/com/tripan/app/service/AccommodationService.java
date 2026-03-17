package com.tripan.app.service;

import java.util.List;

import com.tripan.app.domain.dto.AccommodationDetailDto;
import com.tripan.app.domain.dto.AccommodationDto;
import com.tripan.app.domain.dto.AdSearchConditionDto;
import com.tripan.app.domain.dto.ReservationRequestDto;
import com.tripan.app.domain.dto.ReviewDto;
import com.tripan.app.domain.dto.ReviewStatsDto;
import com.tripan.app.domain.dto.RoomDto;

public interface AccommodationService {
	public List<AccommodationDto> searchAccommodations(AdSearchConditionDto condition);
	
	public AccommodationDetailDto getAccommodationDetail(Long placeId, Long memberId, String checkin, String checkout);
	
	public RoomDto findRoomById(String roomId);
	
	
	public boolean acquireLock(String roomId, String checkin, String checkout, String sessionId);
    public void releaseLock(String roomId, String checkin, String sessionId);
    
    
    public void processReservation(ReservationRequestDto dto, String sessionId);
    
    public boolean toggleBookmark(Long placeId, Long memberId);
    
    public List<String> getFullyBookedDates(Long placeId);
    
    public ReservationRequestDto getReservationInfobyId(Long reservationId);

	public boolean checkReviewExistsByReservationId(Long reservationId);
	
	
	public void insertReview(ReviewDto dto);
	public ReviewStatsDto getReviewStats(Long placeId);
    public List<ReviewDto> getReviewList(Long placeId);
}
