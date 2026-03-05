package com.tripan.app.service;

import com.tripan.app.domain.dto.CommunityChatMessageDto;
import com.tripan.app.mapper.CommunityChatMapper;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class CommunityChatServiceImpl implements CommunityChatService {

    private final CommunityChatMapper chatMapper;

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
}