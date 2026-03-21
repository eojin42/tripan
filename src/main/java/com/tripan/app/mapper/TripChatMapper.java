package com.tripan.app.mapper;

import com.tripan.app.domain.dto.TripChatDto;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

@Mapper
public interface TripChatMapper {

    // ── 채팅방 ──────────────────────────────────────
    Long selectChatRoomIdByTripId(@Param("tripId") Long tripId);
    void insertChatRoom(Map<String, Object> params);

    // ── 채팅 멤버 ─────────────────────────────────────
    int  countChatMember(@Param("chatRoomId") Long chatRoomId,
                         @Param("memberId")  Long memberId);
    void insertChatMember(Map<String, Object> params);
    void updateLastConnected(@Param("chatRoomId") Long chatRoomId,
                             @Param("memberId")   Long memberId);

    // ── 메시지 ─────────────────────────────────────
    List<TripChatDto.MessageResponse> selectMessages(
            @Param("chatRoomId") Long chatRoomId,
            @Param("limit")      int  limit,
            @Param("beforeId")   Long beforeId);

    void insertMessage(Map<String, Object> params);
    TripChatDto.MessageResponse selectMessageById(@Param("messageId") Long messageId);

    int  countUnread(@Param("chatRoomId") Long chatRoomId,
                     @Param("memberId")   Long memberId);

    /**
     * last_connected_at 시점까지 읽은 메시지 중 가장 마지막 message_id 반환.
     * 이 ID 이후가 "읽지 않은 메시지" 구간.
     * unread=0 이거나 메시지가 없으면 null 반환.
     */
    Long selectLastReadMessageId(@Param("chatRoomId") Long chatRoomId,
                                 @Param("memberId")   Long memberId);
}