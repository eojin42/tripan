package com.tripan.app.service;

import java.util.List;
import com.tripan.app.domain.dto.TripDto;

public interface ItineraryService {

    // 새로운 장소 추가
    Long addPlaceAndItinerary(Long tripId, Long dayId, TripDto.PlaceAddDto dto, Long loginMemberId);

    // 드래그앤드롭 전체 순서 배열 업데이트 (기존 방식)
    void updateVisitOrder(Long tripId, List<ItemOrderDto> orderList);

    // 시간이나 메모 수정
    void updateItemDetails(Long tripId, Long itemId, String startTime, String memo);

    // 일정 삭제 (tripId 포함 기존 버전)
    void deleteItineraryItem(Long tripId, Long itemId);

    // 메모 + 이미지 저장
    String saveMemoAndImage(Long itemId, String memo, String imageBase64, Long loginMemberId);

    // ─────────────────────────────────────────────────────────
    // ✅ 아래 3개: ItineraryController (WS 연동) 에서 사용
    // ─────────────────────────────────────────────────────────

    /**
     * itemId → dayId → TripDay → tripId 경로로 tripId 반환
     * WebSocket broadcast 시 어느 방으로 보낼지 알아야 함
     */
    Long getTripIdByItemId(Long itemId);

    /**
     * 드래그앤드롭 단건 이동
     * - itemId: 이동할 장소 카드
     * - dayNumber: 이동 목적지 일차 번호 (1일차, 2일차...)
     * - visitOrder: LexoRank String ("000001", "000002"...)
     */
    void moveItem(Long itemId, int dayNumber, String visitOrder);

    /**
     * 장소 단건 삭제 (tripId 없이 itemId만으로)
     */
    void deleteItem(Long itemId);

    // 순서 변경용 DTO
    class ItemOrderDto {
        private Long itemId;
        private String visitOrder;

        public Long getItemId() { return itemId; }
        public String getVisitOrder() { return visitOrder; }
        public void setItemId(Long itemId) { this.itemId = itemId; }
        public void setVisitOrder(String visitOrder) { this.visitOrder = visitOrder; }
    }
}
