package com.tripan.app.service;

import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.tripan.app.config.WebSocketEventListener;
import com.tripan.app.domain.dto.CommunityChatMessageDto;
import com.tripan.app.domain.dto.CommunityChatRoomDto;
import com.tripan.app.mapper.CommunityChatMapper;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class CommunityChatServiceImpl implements CommunityChatService {

    private final CommunityChatMapper chatMapper;
	private final WebSocketEventListener contentEventListener;

    @Override
    @Transactional 
    public void saveMessage(CommunityChatMessageDto message) {
        chatMapper.insertMessage(message);
        
    }

    @Override
    public List<CommunityChatMessageDto> getChatHistory(Long roomId) {
        return chatMapper.selectChatHistory(roomId);
    }
    
    @Override
    public List<CommunityChatRoomDto> getAllChatRooms() {
        return chatMapper.selectAllChatRooms();
    }
    
    @Override
    public List<CommunityChatRoomDto> getTopChatRooms() {
        List<CommunityChatRoomDto> allRooms = chatMapper.selectAllChatRooms();
        
        Map<String, AtomicInteger> liveCounts = contentEventListener.getRoomUserCount();
        
        return allRooms.stream()
                .peek(room -> {
                    AtomicInteger count = liveCounts.get(String.valueOf(room.getChatRoomId()));
                    room.setUserCount(count != null ? count.get() : 0);
                })
                .sorted(Comparator.comparingInt(CommunityChatRoomDto::getUserCount).reversed())
                .limit(3) 
                .collect(Collectors.toList());
    }
    
    @Override
    @Transactional 
    public Long getOrMakePrivateChat(Long myId, Long targetId) {
        Long existingRoomId = chatMapper.findPrivateRoom(myId, targetId);
        if (existingRoomId != null) {
            return existingRoomId;
        }

        CommunityChatRoomDto newRoom = new CommunityChatRoomDto();
        newRoom.setChatRoomName("1:1 대화방");
        chatMapper.insertChatRoom(newRoom);
        Long newRoomId = newRoom.getChatRoomId();

        chatMapper.insertChatMember(newRoomId, myId);
        chatMapper.insertChatMember(newRoomId, targetId);

        return newRoomId;
    }
    
    @Override
    public List<CommunityChatRoomDto> getRegionRooms() {
        return chatMapper.selectRegionRooms();
    }

    @Override
    public List<CommunityChatRoomDto> getMyPrivateRooms(Long memberId) {
        return chatMapper.selectMyPrivateRooms(memberId);
    }

	@Override
	public String getRoomType(Long roomId) {
		try {
            return chatMapper.selectRoomType(roomId);
        } catch (Exception e) {
            return null;
        }
    }

	
}