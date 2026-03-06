package com.tripan.app.mapper;

import com.tripan.app.domain.dto.CommunityChatMessageDto;
import com.tripan.app.domain.dto.CommunityChatRoomDto;

import org.apache.ibatis.annotations.Mapper;
import java.util.List;

@Mapper 
public interface CommunityChatMapper {
    
    void insertMessage(CommunityChatMessageDto message);
    List<CommunityChatMessageDto> selectChatHistory(Long roomId);
    List<CommunityChatRoomDto> selectAllChatRooms();
}