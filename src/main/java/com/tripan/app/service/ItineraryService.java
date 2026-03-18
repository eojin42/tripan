package com.tripan.app.service;

import java.util.List;
import com.tripan.app.domain.dto.TripDto;

public interface ItineraryService {

    Long addPlaceAndItinerary(Long tripId, Long dayId, TripDto.PlaceAddDto dto, Long loginMemberId);

    void updateVisitOrder(Long tripId, List<ItemOrderDto> orderList);

    void updateItemDetails(Long tripId, Long itemId, String startTime, String memo);

    void deleteItineraryItem(Long tripId, Long itemId);

    /**
     * 메모 + 다중 이미지 저장 (최대 3장)
     *
     * @param keepImageUrls 유지할 기존 이미지 URL 목록. null이면 기존 이미지 전부 삭제(구버전 동작).
     * @return 최종 저장된 이미지 URL 목록 (유지된 기존 + 새로 추가된)
     */
    List<String> saveMemoAndImages(Long itemId, String memo,
                                   List<String> imageBase64List,
                                   List<String> keepImageUrls,
                                   Long loginMemberId);

    Long getTripIdByItemId(Long itemId);

    /** 장소 삭제 알림 메시지용 — 삭제 전 장소명 조회 */
    String getPlaceNameByItemId(Long itemId);

    void moveItem(Long itemId, int dayNumber, String visitOrder);

    void deleteItem(Long itemId);

    class ItemOrderDto {
        private Long itemId;
        private String visitOrder;
        public Long getItemId() { return itemId; }
        public String getVisitOrder() { return visitOrder; }
        public void setItemId(Long itemId) { this.itemId = itemId; }
        public void setVisitOrder(String visitOrder) { this.visitOrder = visitOrder; }
    }
}
