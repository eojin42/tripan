package com.tripan.app.websocket;

import lombok.*;
import java.util.Map;

/**
 * WebSocket 브로드캐스트 메시지 DTO
 *
 * ┌─ 저장 흐름 ──────────────────────────────────────────────────┐
 * │  사용자 액션 → REST fetch() → DB 저장(영속) → broadcast      │
 * │  → 같은 방 다른 사용자들 DOM 갱신 (새로고침 없이)             │
 * │                                                              │
 * │  재진입 시: JSP 렌더링 → DB 조회 → 항상 최신 상태            │
 * └──────────────────────────────────────────────────────────────┘
 *
 * type 목록:
 *   ORDER_UPDATED     드래그앤드롭 순서/DAY 변경
 *   PLACE_ADDED       장소 추가
 *   PLACE_DELETED     장소 삭제
 *   MEMO_UPDATED      메모/시간 수정
 *   CHECKLIST_ADDED   체크리스트 항목 추가
 *   CHECKLIST_TOGGLED 체크박스 ON/OFF
 *   CHECKLIST_DELETED 체크리스트 삭제
 *   EXPENSE_ADDED     가계부 지출 추가
 *   EXPENSE_DELETED   가계부 삭제
 *   VOTE_CREATED      투표 생성
 *   VOTE_CASTED       투표 참여
 *   VOTE_DELETED      투표 삭제
 *   TRIP_UPDATED      여행 기본 정보 수정
 *   MEMBER_JOINED     새 멤버 참여
 */
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
public class WorkspaceMessage {

    private String type;
    private Long   tripId;
    private Long   targetId;
    private String senderNickname;
    private Map<String, Object> payload;
}
