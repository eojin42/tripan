package com.tripan.app.partner.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.tripan.app.partner.domain.dto.PartnerRoomDto;

@Mapper
public interface PartnerRoomMapper {
    List<PartnerRoomDto> getRoomListByMemberId(Long memberId);
    List<PartnerRoomDto> getRoomsByPlaceId(Long placeId);
    
    void insertRoomFacility(PartnerRoomDto dto);
    void insertRoom(PartnerRoomDto dto);
    void insertRoomImage(@Param("roomId") String roomId, @Param("imageUrl") String imageUrl);
    
    String getRfIdByRoomId(String roomId); 
    void deleteRoomImages(String roomId);  
    void deleteRoom(String roomId);       
    void deleteRoomFacility(String rfId);  
    
    void updateRoom(PartnerRoomDto dto);
    void updateRoomFacility(PartnerRoomDto dto);
    
    List<Map<String, Object>> selectReservationsForCalendar( @Param("placeId") Long placeId, 
    														 @Param("start") String startDate, 
    														 @Param("end") String endDate );
    
    
    List<Map<String, Object>> selectBookingListForPartner( @Param("placeId") Long placeId);
}