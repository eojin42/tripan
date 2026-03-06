package com.tripan.app.service;

import com.tripan.app.domain.dto.CommunityChatMessageDto;
import com.tripan.app.domain.dto.CommunityChatRoomDto;

import java.util.List;

public interface CommunityChatService {
    void saveMessage(CommunityChatMessageDto message);
    
    List<CommunityChatMessageDto> getChatHistory(Long roomId);
    List<CommunityChatRoomDto> getAllChatRooms();
    
    List<CommunityChatRoomDto> getTopChatRooms();
}