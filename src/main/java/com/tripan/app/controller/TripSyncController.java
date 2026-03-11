package com.tripan.app.controller;

import java.util.Map;

import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;

import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor
public class TripSyncController {

    private final SimpMessagingTemplate messagingTemplate;

    // 장소 추가 동기화
    @MessageMapping("/trip/{tripId}/item/add")
    public void handleAddItem(@DestinationVariable Long tripId, @Payload Map<String, Object> payload) {
        payload.put("action", "ADD_ITEM");
        
        messagingTemplate.convertAndSend("/sub/trip/" + tripId, payload);
    }

    // 순서 변경 동기화 (드래그 앤 드롭)
    @MessageMapping("/trip/{tripId}/item/reorder")
    public void handleReorder(@DestinationVariable Long tripId, @Payload Map<String, Object> payload) {
        payload.put("action", "REORDER_ITEM");
        messagingTemplate.convertAndSend("/sub/trip/" + tripId, payload);
    }

    // 시간 및 메모 수정 동기화 (타이핑할 때마다 또는 포커스 아웃 시)
    @MessageMapping("/trip/{tripId}/item/update")
    public void handleUpdateItem(@DestinationVariable Long tripId, @Payload Map<String, Object> payload) {
        payload.put("action", "UPDATE_ITEM");
        messagingTemplate.convertAndSend("/sub/trip/" + tripId, payload);
    }

    // 장소 삭제 동기화
    @MessageMapping("/trip/{tripId}/item/delete")
    public void handleDeleteItem(@DestinationVariable Long tripId, @Payload Map<String, Object> payload) {
        payload.put("action", "DELETE_ITEM");
        messagingTemplate.convertAndSend("/sub/trip/" + tripId, payload);
    }

    // 투표 동기화 (누군가 투표를 클릭했을 때)
    @MessageMapping("/trip/{tripId}/vote")
    public void handleVote(@DestinationVariable Long tripId, @Payload Map<String, Object> payload) {
        payload.put("action", "UPDATE_VOTE");
        messagingTemplate.convertAndSend("/sub/trip/" + tripId, payload);
    }
    
    // 체크리스트 체크 동기화
    @MessageMapping("/trip/{tripId}/checklist")
    public void handleChecklist(@DestinationVariable Long tripId, @Payload Map<String, Object> payload) {
        payload.put("action", "UPDATE_CHECKLIST");
        messagingTemplate.convertAndSend("/sub/trip/" + tripId, payload);
    }
}