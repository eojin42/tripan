package com.tripan.app.admin.service;

import java.util.List;

import com.tripan.app.admin.domain.dto.ChatMemberManageDto;
import com.tripan.app.admin.domain.dto.ChatMessageManageDto;
import com.tripan.app.admin.domain.dto.ChatRoomManageDto;

public interface ChatRoomManageService {

    /* ── 목록 조회 ── */
    List<ChatRoomManageDto> getAllRooms();

    /* ── 단건 조회 ── */
    ChatRoomManageDto getRoomById(Long chatRoomId);

    /* ── 채팅방 개설 ── */
    ChatRoomManageDto createRoom(ChatRoomManageDto.CreateRequest request);

    /* ── 활성/비활성 변경 ── */
    void updateStatus(Long chatRoomId, String status);

    /* ── 채팅방 삭제 ── */
    void deleteRoom(Long chatRoomId);

    /* ── 통계 ── */
    ChatRoomManageDto.StatsResponse getStats();

    /* ── 입장 멤버 목록 ── */
    List<ChatMemberManageDto> getMembers(Long chatRoomId);

    /* ── 강퇴 ── */
    void kickMember(Long chatRoomId, Long memberId);

    /* ── 차단 ── */
    void blockMember(Long chatRoomId, Long memberId);

    /* ── 채팅 내역 ── */
    List<ChatMessageManageDto> getMessages(Long chatRoomId, int size, String searchDate);
}