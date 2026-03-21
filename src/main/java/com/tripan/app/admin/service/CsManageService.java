package com.tripan.app.admin.service;

import java.util.List;

import com.tripan.app.admin.domain.dto.ChatRoomManageDto;
import com.tripan.app.domain.dto.CommunityChatRoomDto;

public interface CsManageService {
    List<CommunityChatRoomDto> getSupportRoomsByMemberId(Long memberId);
    CommunityChatRoomDto createSupportRoom(Long memberId);
    List<ChatRoomManageDto> getAllSupportRooms();
    void closeRoom(Long roomId);
    void resetNotification(Long roomId, Long adminId);
    void reopenRoomIfClosed(Long roomId);
}
