package com.tripan.app.partner.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import com.tripan.app.partner.domain.dto.PartnerRoomDto;
import java.util.List;

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
}