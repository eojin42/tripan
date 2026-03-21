package com.tripan.app.service;

import com.tripan.app.domain.dto.TripChatDto;
import java.util.List;

public interface TripChatService {

    Long getOrCreateChatRoom(Long tripId, String tripName, Long memberId);
    void joinIfAbsent(Long chatRoomId, Long memberId);

    TripChatDto.MessageResponse sendMessage(Long chatRoomId, Long memberId,
                                            String content, String messageType);

    List<TripChatDto.MessageResponse> getMessages(Long chatRoomId, int limit, Long beforeId);

    int  countUnread(Long chatRoomId, Long memberId);
    void markRead(Long chatRoomId, Long memberId);

    /**
     * 내가 마지막으로 읽은 message_id 반환.
     * null이면 처음 진입이거나 unread 구분 불필요.
     */
    Long getLastReadMessageId(Long chatRoomId, Long memberId);
}