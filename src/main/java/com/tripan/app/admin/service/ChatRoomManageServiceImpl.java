package com.tripan.app.admin.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.tripan.app.admin.domain.dto.ChatMemberManageDto;
import com.tripan.app.admin.domain.dto.ChatMessageManageDto;
import com.tripan.app.admin.domain.dto.ChatRoomManageDto;
import com.tripan.app.admin.mapper.ChatRoomManageMapper;

import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class ChatRoomManageServiceImpl implements ChatRoomManageService {

	private final ChatRoomManageMapper chatRoomMapper;
	 
    @Override
    @Transactional(readOnly = true)
    public List<ChatRoomManageDto> getAllRooms() {
        return chatRoomMapper.selectAllRooms();
    }
 
    @Override
    @Transactional(readOnly = true)
    public ChatRoomManageDto getRoomById(Long chatRoomId) {
    	ChatRoomManageDto room = chatRoomMapper.selectRoomById(chatRoomId);
        if (room == null) {
            throw new IllegalArgumentException("존재하지 않는 채팅방입니다. id=" + chatRoomId);
        }
        return room;
    }
 
    @Override
    @Transactional
    public ChatRoomManageDto createRoom(ChatRoomManageDto.CreateRequest request) {
        validateCreateRequest(request);
 
        ChatRoomManageDto dto = ChatRoomManageDto.builder()
                .chatRoomName(request.getChatRoomName())
                .chatRoomType(request.getChatRoomType())
                .regionId(request.getRegionId())
                .status(request.getStatus() != null ? request.getStatus() : "ACTIVE")
                .build();
 
        chatRoomMapper.insertRoom(dto);
        log.info("[ChatRoom] 개설 완료: id={}, name={}", dto.getChatRoomId(), dto.getChatRoomName());
 
        return chatRoomMapper.selectRoomById(dto.getChatRoomId());
    }
 
    @Override
    @Transactional
    public void updateStatus(Long chatRoomId, String status) {
        if (!"ACTIVE".equals(status) && !"CLOSED".equals(status)) {
            throw new IllegalArgumentException("status 값은 ACTIVE 또는 CLOSED여야 합니다.");
        }
        int affected = chatRoomMapper.updateStatus(chatRoomId, status);
        if (affected == 0) {
            throw new IllegalArgumentException("존재하지 않는 채팅방입니다. id=" + chatRoomId);
        }
        log.info("[ChatRoom] 상태 변경: id={}, status={}", chatRoomId, status);
    }
 
    @Override
    @Transactional
    public void deleteRoom(Long chatRoomId) {
        int affected = chatRoomMapper.deleteRoom(chatRoomId);
        if (affected == 0) {
            throw new IllegalArgumentException("존재하지 않는 채팅방입니다. id=" + chatRoomId);
        }
        log.info("[ChatRoom] 삭제: id={}", chatRoomId);
    }
 
    @Override
    @Transactional(readOnly = true)
    public ChatRoomManageDto.StatsResponse getStats() {
        int total        = chatRoomMapper.countTotal();
        int active       = chatRoomMapper.countActive();
        int todayMsg     = chatRoomMapper.countTodayMessages();
        int totalRegion  = chatRoomMapper.countByType("REGION");
        int totalCs      = chatRoomMapper.countByType("WORKSPACE");
        int activeRegion = chatRoomMapper.countActiveByType("REGION");
        int activeCs     = chatRoomMapper.countActiveByType("WORKSPACE");
 
        int online = chatRoomMapper.selectAllRooms().stream()
                .mapToInt(r -> r.getOnlineCount() != null ? r.getOnlineCount() : 0)
                .sum();
 
        return ChatRoomManageDto.StatsResponse.builder()
                .total(total)
                .active(active)
                .onlineUsers(online)
                .todayMessages(todayMsg)
                .totalRegion(totalRegion)
                .totalCs(totalCs)
                .activeRegion(activeRegion)
                .activeCs(activeCs)
                .build();
    }
 
    @Override
    @Transactional(readOnly = true)
    public List<ChatMemberManageDto> getMembers(Long chatRoomId) {
        return chatRoomMapper.selectMembersByRoomId(chatRoomId);
    }
 
    @Override
    @Transactional
    public void kickMember(Long chatRoomId, Long memberId) {
        int affected = chatRoomMapper.updateMemberStatus(chatRoomId, memberId, "KICKED");
        if (affected == 0) throw new IllegalArgumentException("해당 멤버를 찾을 수 없습니다.");
        log.info("[ChatRoom] 강퇴: roomId={}, memberId={}", chatRoomId, memberId);
    }
 
    @Override
    @Transactional
    public void blockMember(Long chatRoomId, Long memberId) {
        int affected = chatRoomMapper.updateMemberStatus(chatRoomId, memberId, "BLOCKED");
        if (affected == 0) throw new IllegalArgumentException("해당 멤버를 찾을 수 없습니다.");
        log.info("[ChatRoom] 차단: roomId={}, memberId={}", chatRoomId, memberId);
    }
 
    @Override
    @Transactional(readOnly = true)
    public List<ChatMessageManageDto> getMessages(Long chatRoomId, int size, String searchDate) {
        int safeSize = (size <= 0 || size > 200) ? 100 : size;
        return chatRoomMapper.selectMessagesByRoomId(chatRoomId, safeSize, searchDate);
    }
 
    private void validateCreateRequest(ChatRoomManageDto.CreateRequest req) {
        if (req.getChatRoomName() == null || req.getChatRoomName().isBlank()) {
            throw new IllegalArgumentException("채팅방 이름은 필수입니다.");
        }
        if (req.getChatRoomName().length() > 100) {
            throw new IllegalArgumentException("채팅방 이름은 100자 이하여야 합니다.");
        }
        if (req.getChatRoomType() == null || req.getChatRoomType().isBlank()) {
            throw new IllegalArgumentException("채팅방 타입은 필수입니다.");
        }
        if (!List.of("REGION", "SUPPORT").contains(req.getChatRoomType())) {
            throw new IllegalArgumentException("유효하지 않은 타입입니다: " + req.getChatRoomType());
        }
    }
}