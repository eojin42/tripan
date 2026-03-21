package com.tripan.app.admin.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.tripan.app.admin.domain.dto.ChatMemberManageDto;
import com.tripan.app.admin.domain.dto.ChatMessageManageDto;
import com.tripan.app.admin.domain.dto.ChatRoomManageDto;

import java.util.List;

@Mapper
public interface ChatRoomManageMapper {

    /* ── 목록 조회 ── */
    List<ChatRoomManageDto> selectAllRooms();

    /* ── 단건 조회 ── */
    ChatRoomManageDto selectRoomById(@Param("chatRoomId") Long chatRoomId);

    /* ── 채팅방 개설 ── */
    int insertRoom(ChatRoomManageDto chatRoomDto);

    /* ── 활성/비활성 변경 ── */
    int updateStatus(@Param("chatRoomId") Long chatRoomId,
                     @Param("status")     String status);

    /* ── 채팅방 삭제 ── */
    int deleteRoom(@Param("chatRoomId") Long chatRoomId);

    /* ── 통계: 전체 방 수 ── */
    int countTotal();

    /* ── 통계: 활성 방 수 ── */
    int countActive();

    /* ── 통계: 오늘 메시지 수 ── */
    int countTodayMessages();

    /* ── 입장 멤버 목록 ── */
    List<ChatMemberManageDto> selectMembersByRoomId(@Param("chatRoomId") Long chatRoomId);

    /* ── 강퇴 ── */
    int updateMemberStatus(@Param("chatRoomId") Long chatRoomId,
                           @Param("memberId")   Long memberId,
                           @Param("adminStatus") String adminStatus);

    /* ── 채팅 내역 조회 (최신 N건) ── */
    List<ChatMessageManageDto> selectMessagesByRoomId(@Param("chatRoomId") Long chatRoomId,
                                                @Param("size") int size, @Param("searchDate") String searchDate);

    /* 타입별 전체 수 */
    int countByType(@Param("type") String type);

    /* 타입별 활성 수 */
    int countActiveByType(@Param("type") String type);

}