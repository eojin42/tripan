package com.tripan.app.admin.service;

import java.util.List;

import com.tripan.app.domain.dto.CommunityChatRoomDto;

public interface CsManageService {
	List<CommunityChatRoomDto> getSupportRoomsByMemberId(Long memberId);
    CommunityChatRoomDto createSupportRoom(Long memberId);
}
