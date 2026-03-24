package com.tripan.app.partner.service;

import java.util.List;
import java.util.Map;

import org.springframework.web.multipart.MultipartFile;

import com.tripan.app.domain.dto.AccommodationDetailDto;
import com.tripan.app.partner.domain.dto.PartnerRoomDto;

public interface PartnerRoomService {
    void registerNewRoom(PartnerRoomDto dto, List<MultipartFile> images) throws Exception;
    
    void deleteRoom(String roomId) throws Exception;
    
    void saveRoomImages(String roomId, List<MultipartFile> images);
    
    List<Map<String, Object>> getCalendarEvents(Long placeId, String start, String end);
    
    void cancelReservationByPartner(Long reservationId, Long partnerId, String cancelReason);
    
    void updateRoomInfo(PartnerRoomDto dto, List<MultipartFile> images) throws Exception;
    
    List<Map<String, Object>> getBookingListForPartner(Map<String, Object> params);
    
    AccommodationDetailDto getAccommodationDetailForPartner(Long placeId, Long memberId);

    List<PartnerRoomDto> getRoomsByPlaceId(Long placeId);
    
    
}