package com.tripan.app.service;

import com.tripan.app.domain.dto.CommunityChatMessageDto;

import java.util.List;

public interface CommunityChatService {
    void saveMessage(CommunityChatMessageDto message);
    
    List<CommunityChatMessageDto> getChatHistory(Long roomId);
}