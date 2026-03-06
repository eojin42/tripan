package com.tripan.app.service;

import com.tripan.app.config.WebSocketEventListener;
import com.tripan.app.domain.dto.CommunityChatMessageDto;
import com.tripan.app.domain.dto.CommunityChatRoomDto;
import com.tripan.app.mapper.CommunityChatMapper;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CommunityChatServiceImpl implements CommunityChatService {

    private final CommunityChatMapper chatMapper;
	private final WebSocketEventListener contentEventListener;

    @Override
    @Transactional // DB 작업이므로 트랜잭션 처리를 해주는 것이 안전합니다.
    public void saveMessage(CommunityChatMessageDto message) {
        // 컨트롤러에서 넘어온 DTO 데이터를 Mapper를 통해 DB에 저장합니다.
        chatMapper.insertMessage(message);
    }

    @Override
    public List<CommunityChatMessageDto> getChatHistory(Long roomId) {
        // 나중에 상담 채팅이나 워크스페이스 채팅 시 과거 내역을 불러올 때 사용합니다.
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
                .limit(3) // 최상단부터 몇개 가져올건지 조절 가능 
                .collect(Collectors.toList());
    }
    
}