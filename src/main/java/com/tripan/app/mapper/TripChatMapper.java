package com.tripan.app.mapper;

import com.tripan.app.domain.dto.TripChatDto;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

@Mapper
public interface TripChatMapper {

    // ── 채팅방 ──────────────────────────────────────
    /** 여행 ID로 WORKSPACE 채팅방 조회 */
    Long selectChatRoomIdByTripId(@Param("tripId") Long tripId);

    /** 채팅방 생성 */
    void insertChatRoom(Map<String, Object> params);

    // ── 채팅 멤버 ─────────────────────────────────────
    /** 이미 채팅방 멤버인지 확인 */
    int countChatMember(@Param("chatRoomId") Long chatRoomId,
                        @Param("memberId")  Long memberId);

    /** 채팅방 참여 */
    void insertChatMember(Map<String, Object> params);

    /** 마지막 접속 시각 갱신 */
    void updateLastConnected(@Param("chatRoomId") Long chatRoomId,
                             @Param("memberId")   Long memberId);

    // ── 메시지 ─────────────────────────────────────
    /** 최근 메시지 조회 (최신순 N개 → 뒤집어서 리턴) */
    List<TripChatDto.MessageResponse> selectMessages(
            @Param("chatRoomId") Long chatRoomId,
            @Param("limit")      int  limit,
            @Param("beforeId")   Long beforeId);   // null이면 최신부터

    /** 메시지 저장 후 생성된 message_id 반환 */
    void insertMessage(Map<String, Object> params);

    /** 방금 저장된 메시지 단건 조회 */
    TripChatDto.MessageResponse selectMessageById(@Param("messageId") Long messageId);

    /** 안 읽은 메시지 수 (last_connected_at 이후) */
    int countUnread(@Param("chatRoomId") Long chatRoomId,
                    @Param("memberId")   Long memberId);
}
