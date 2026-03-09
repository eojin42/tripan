package com.tripan.app.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.tripan.app.domain.dto.CommunityChatMessageDto;
import com.tripan.app.domain.dto.CommunityChatRoomDto;

@Mapper 
public interface CommunityChatMapper {
    
    void insertMessage(CommunityChatMessageDto message);
    List<CommunityChatMessageDto> selectChatHistory(Long roomId);
    List<CommunityChatRoomDto> selectAllChatRooms();
    
    Long findPrivateRoom(@Param("myId") Long myId, @Param("targetId") Long targetId);
    void insertChatRoom(CommunityChatRoomDto room);
    void insertChatMember(@Param("roomId") Long roomId, @Param("memberId") Long memberId);
    
    List<CommunityChatRoomDto> selectRegionRooms();
    List<CommunityChatRoomDto> selectMyPrivateRooms(Long memberId);
}