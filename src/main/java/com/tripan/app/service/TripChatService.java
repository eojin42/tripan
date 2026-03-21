package com.tripan.app.service;

import com.tripan.app.domain.dto.TripChatDto;
import java.util.List;

public interface TripChatService {

    /**
     * WORKSPACE 채팅방 조회 또는 생성.
     * 해당 멤버가 채팅방에 없으면 자동 가입.
     * @return chatRoomId
     */
    Long getOrCreateChatRoom(Long tripId, String tripName, Long memberId);

    /** 채팅방 참여 (trip_member ACCEPTED 확인 후) */
    void joinIfAbsent(Long chatRoomId, Long memberId);

    /** 메시지 전송 → DB 저장, 저장된 메시지 반환 */
    TripChatDto.MessageResponse sendMessage(Long chatRoomId, Long memberId,
                                            String content, String messageType);

    /** 최근 메시지 목록 (오래된 순으로 정렬해서 반환) */
    List<TripChatDto.MessageResponse> getMessages(Long chatRoomId, int limit, Long beforeId);

    /** 안 읽은 메시지 수 */
    int countUnread(Long chatRoomId, Long memberId);

    /** 채팅창 열었을 때 last_connected_at 갱신 */
    void markRead(Long chatRoomId, Long memberId);
}
