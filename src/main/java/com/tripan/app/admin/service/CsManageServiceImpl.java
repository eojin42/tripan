package com.tripan.app.admin.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;

import com.tripan.app.admin.domain.dto.AdminChatRoomDto;
import com.tripan.app.admin.mapper.CsManageMapper;
import com.tripan.app.domain.dto.CommunityChatRoomDto;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class CsManageServiceImpl implements CsManageService {
    private final CsManageMapper csMapper;

    @Override
    public List<CommunityChatRoomDto> getSupportRoomsByMemberId(Long memberId) {
        return csMapper.findSupportRooms(memberId);
    }

    @Override
    public CommunityChatRoomDto createSupportRoom(Long memberId) {
        Long adminId = csMapper.selectAdminMemberId();

        if (adminId == null) {
            throw new IllegalStateException("관리자 계정이 없습니다.");
        }

        Map<String, Object> roomParams = new HashMap<>();
        roomParams.put("memberId", memberId);
        roomParams.put("roomName", "Tripan 고객 상담");
        csMapper.insertSupportRoom(roomParams);

        Long roomId = (Long) roomParams.get("roomId");

        csMapper.insertRoomMember(Map.of("chatRoomId", roomId, "memberId", memberId));
        csMapper.insertRoomMember(Map.of("chatRoomId", roomId, "memberId", adminId));

        return csMapper.selectRoomById(roomId);
    }

    @Override
    public void closeRoom(Long roomId) {
        csMapper.updateRoomStatus(Map.of("roomId", roomId, "status", "CLOSED"));
    }

	@Override
	public void resetNotification(Long roomId, Long adminId) {
		csMapper.updateAdminLastConnected(Map.of("roomId",roomId,"adminId",adminId));
	}

	@Override
	public List<AdminChatRoomDto> getAllSupportRooms() {
		return csMapper.selectAllSupportRooms();
	}
}
