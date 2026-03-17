package com.tripan.app.partner.mapper;

import org.apache.ibatis.annotations.Mapper;
import com.tripan.app.partner.domain.dto.PartnerRoomDto;
import java.util.List;

@Mapper
public interface PartnerRoomMapper {
    List<PartnerRoomDto> getRoomListByMemberId(Long memberId);
    
    void insertRoom(PartnerRoomDto dto);
}