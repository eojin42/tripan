package com.tripan.app.service;

import java.util.List;

// 일정 편집 
public interface ItineraryService { 

    /**
     * 새로운 장소 추가
     * 프론트에서 넘어온 장소 ID를 해당 일차(Day)의 맨 마지막 순서로 추가
     * @param dayId 장소를 추가할 일차(TripDay)의 ID
     * @param tripPlaceId 추가할 장소(TripPlace)의 ID
     * @return 생성된 일정 항목의 ID (itineraryItemId)
     */
	public Long addItineraryItem(Long dayId, Long tripPlaceId);

    /**
     * 드래그 앤 드롭으로 순서 바꾸기 (배열로 받아서 일괄 업데이트)
     * @param orderList 프론트에서 넘어온 [{itemId: 1, visitOrder: 1}, {itemId: 2, visitOrder: 2}] 형태의 리스트
     */
	public void updateVisitOrder(List<ItemOrderDto> orderList);

    /**
     * 시간이나 메모 수정
     * 일정 항목을 클릭해서 방문 시간이나 개별 메모를 덮어씌움
     * @param itemId 수정할 일정 항목 ID
     * @param startTime 시작 시간 (예: "14:00")
     * @param memo 장소별 메모 (예: "츄러스 꼭 먹기")
     */
	public void updateItemDetails(Long itemId, String startTime, String memo);

    /**
     * 일정 삭제
     * @param itemId 삭제할 일정 항목 ID
     */
	public void deleteItineraryItem(Long itemId);
    
	
    // (DTO 내부 클래스 - 순서 변경용)
    public static class ItemOrderDto {
        private Long itemId;
        private Integer visitOrder;
        
        public Long getItemId() { return itemId; }
        public Integer getVisitOrder() { return visitOrder; }
    }
}