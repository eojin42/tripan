package com.tripan.app.service;

import com.tripan.app.domain.dto.TripChatDto;
import com.tripan.app.mapper.TripChatMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class TripChatServiceImpl implements TripChatService {

    private final TripChatMapper chatMapper;

    @Override
    @Transactional
    public Long getOrCreateChatRoom(Long tripId, String tripName, Long memberId) {
        Long chatRoomId = chatMapper.selectChatRoomIdByTripId(tripId);

        if (chatRoomId == null) {
            // 채팅방 없으면 생성
            Map<String, Object> params = new HashMap<>();
            params.put("tripId",       tripId);
            params.put("chatRoomName", tripName != null ? tripName : "여행 채팅");
            chatMapper.insertChatRoom(params);
            chatRoomId = chatMapper.selectChatRoomIdByTripId(tripId);
        }

        joinIfAbsent(chatRoomId, memberId);
        return chatRoomId;
    }

    @Override
    @Transactional
    public void joinIfAbsent(Long chatRoomId, Long memberId) {
        int exists = chatMapper.countChatMember(chatRoomId, memberId);
        if (exists == 0) {
            Map<String, Object> params = new HashMap<>();
            params.put("chatRoomId", chatRoomId);
            params.put("memberId",   memberId);
            chatMapper.insertChatMember(params);
        }
    }

    @Override
    @Transactional
    public TripChatDto.MessageResponse sendMessage(Long chatRoomId, Long memberId,
                                                   String content, String messageType) {
        if (content == null || content.trim().isEmpty()) {
            throw new IllegalArgumentException("메시지 내용이 비어 있습니다.");
        }

        Map<String, Object> params = new HashMap<>();
        params.put("chatRoomId",   chatRoomId);
        params.put("memberId",     memberId);
        params.put("content",      content.trim());
        params.put("messageType",  messageType != null ? messageType : "TALK");

        chatMapper.insertMessage(params);

        Long messageId = (Long) params.get("messageId");
        return chatMapper.selectMessageById(messageId);
    }

    @Override
    public List<TripChatDto.MessageResponse> getMessages(Long chatRoomId, int limit, Long beforeId) {
        List<TripChatDto.MessageResponse> desc = chatMapper.selectMessages(chatRoomId, limit, beforeId);
        // DB는 최신순 → 뒤집어서 오래된 순으로 반환
        List<TripChatDto.MessageResponse> asc = new ArrayList<>(desc);
        Collections.reverse(asc);
        return asc;
    }

    @Override
    public int countUnread(Long chatRoomId, Long memberId) {
        return chatMapper.countUnread(chatRoomId, memberId);
    }

    @Override
    @Transactional
    public void markRead(Long chatRoomId, Long memberId) {
        chatMapper.updateLastConnected(chatRoomId, memberId);
    }

    @Override
    public Long getLastReadMessageId(Long chatRoomId, Long memberId) {
        return chatMapper.selectLastReadMessageId(chatRoomId, memberId);
    }
}