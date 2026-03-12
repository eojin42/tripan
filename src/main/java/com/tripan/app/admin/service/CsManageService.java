package com.tripan.app.admin.service;

import java.util.List;

import com.tripan.app.admin.domain.dto.AdminChatRoomDto;
import com.tripan.app.domain.dto.CommunityChatRoomDto;

public interface CsManageService {
    List<CommunityChatRoomDto> getSupportRoomsByMemberId(Long memberId);
    CommunityChatRoomDto createSupportRoom(Long memberId);
    List<AdminChatRoomDto> getAllSupportRooms();
    void closeRoom(Long roomId);
    void resetNotification(Long roomId, Long adminId);
}
