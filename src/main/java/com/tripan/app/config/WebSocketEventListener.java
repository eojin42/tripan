package com.tripan.app.config; 

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.event.EventListener;
import org.springframework.messaging.simp.SimpMessageSendingOperations;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.messaging.SessionDisconnectEvent;
import org.springframework.web.socket.messaging.SessionSubscribeEvent;

import java.util.Collections;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;

@Slf4j
@Component
@RequiredArgsConstructor
public class WebSocketEventListener {

    private final SimpMessageSendingOperations messagingTemplate;
    private final Map<String, AtomicInteger> roomUserCount = new ConcurrentHashMap<>();
    private final Map<String, String> sessionRoomMap = new ConcurrentHashMap<>();

    public Map<String, AtomicInteger> getRoomUserCount() {
        return Collections.unmodifiableMap(roomUserCount);
    }
    
    @EventListener
    public void handleWebSocketSubscribeListener(SessionSubscribeEvent event) {
        StompHeaderAccessor headerAccessor = StompHeaderAccessor.wrap(event.getMessage());
        String destination = headerAccessor.getDestination();
        String sessionId = headerAccessor.getSessionId();

        if (destination != null && destination.startsWith("/sub/chat/room/") && !destination.endsWith("/count")) {
            String roomId = destination.replace("/sub/chat/room/", "");
            
            sessionRoomMap.put(sessionId, roomId);
            
            roomUserCount.putIfAbsent(roomId, new AtomicInteger(0));
            int count = roomUserCount.get(roomId).incrementAndGet();
            
            log.info("🟢 [입장] 방 번호: {}, 현재 인원: {}", roomId, count);

            messagingTemplate.convertAndSend("/sub/chat/room/" + roomId + "/count", count);
        }
    }

    @EventListener
    public void handleWebSocketDisconnectListener(SessionDisconnectEvent event) {
        StompHeaderAccessor headerAccessor = StompHeaderAccessor.wrap(event.getMessage());
        String sessionId = headerAccessor.getSessionId();
        
        String roomId = sessionRoomMap.remove(sessionId);

        if (roomId != null && roomUserCount.containsKey(roomId)) {
            int count = roomUserCount.get(roomId).decrementAndGet();
            
            log.info("🔴 [퇴장] 방 번호: {}, 현재 인원: {}", roomId, count);
            
            if (count <= 0) {
                roomUserCount.remove(roomId);
                count = 0;
            }
            
            messagingTemplate.convertAndSend("/sub/chat/room/" + roomId + "/count", count);
        }
    }
}