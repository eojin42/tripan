package com.tripan.app.service;

import java.util.List;
import com.tripan.app.domain.dto.TripDto;

public interface ItineraryService { 

    // 새로운 장소 추가 
    Long addPlaceAndItinerary(Long tripId, Long dayId, TripDto.PlaceAddDto dto, Long loginMemberId);

    // 드래그 앤 드롭으로 순서 바꾸기 
    void updateVisitOrder(Long tripId, List<ItemOrderDto> orderList);

    
    // 시간이나 메모 수정 
    void updateItemDetails(Long tripId, Long itemId, String startTime, String memo);

    // 일정 삭제
    void deleteItineraryItem(Long tripId, Long itemId);

    /**
     * 장소 카드 📝 버튼 → 메모 + 이미지 저장
     * @param itemId      ItineraryItem PK
     * @param memo        메모 텍스트 (null 허용)
     * @param imageBase64 "data:image/jpeg;base64,..." (null이면 이미지 변경 없음)
     * @return 저장된 imageUrl (없으면 null)
     */
    /**
     * 장소 카드 📝 버튼 → 메모 + 이미지 저장
     * @param loginMemberId 업로드한 멤버 ID (ItineraryImage.memberId)
     */
    String saveMemoAndImage(Long itemId, String memo, String imageBase64, Long loginMemberId);

    // 순서 변경용 DTO 내부 클래스
    class ItemOrderDto {
        private Long itemId;
        private String visitOrder; 
        
        public Long getItemId() { return itemId; }
        public String getVisitOrder() { return visitOrder; }
        public void setItemId(Long itemId) { this.itemId = itemId; }
        public void setVisitOrder(String visitOrder) { this.visitOrder = visitOrder; }
    }
}