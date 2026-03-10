package com.tripan.app.admin.mapper;

import java.util.List;
import java.util.Map;

import com.tripan.app.domain.dto.CommunityChatRoomDto;

public interface CsManageMapper {
	List<CommunityChatRoomDto> findSupportRooms(Long memberId);
    void insertSupportRoom(Map<String, Object> roomParams);
    
    void insertRoomMember(Map<String, Object> params);
    Long selectAdminMemberId();
    CommunityChatRoomDto selectRoomById(Long chatRoomId);

    Long selectLastRoomId();                              
    List<CommunityChatRoomDto> selectAllSupportRooms(); 
    void updateRoomStatus(Map<String, Object> params);
}
