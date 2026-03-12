package com.tripan.app.websocket;

import lombok.RequiredArgsConstructor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.Map;

/**
 * WorkspaceEventPublisher
 *
 * 컨트롤러에서 DB 저장 완료 후 이 클래스로 broadcast 한 줄 호출.
 * 구독 주소: /sub/trip/{tripId}
 */
@Component
@RequiredArgsConstructor
public class WorkspaceEventPublisher {

    private final SimpMessagingTemplate messaging;

    /**
     * 기본 broadcast
     *
     * @param tripId   여행 방 ID
     * @param type     이벤트 타입 (WorkspaceMessage 주석 참고)
     * @param targetId 변경 대상 ID (없으면 null)
     * @param nickname 발신자 닉네임
     * @param payload  추가 데이터
     */
    public void publish(Long tripId, String type, Long targetId,
                        String nickname, Map<String, Object> payload) {

        WorkspaceMessage msg = WorkspaceMessage.builder()
                .type(type)
                .tripId(tripId)
                .targetId(targetId)
                .senderNickname(nickname)
                .payload(payload != null ? payload : new HashMap<>())
                .build();

        // WebSocketConfig: broker "/sub", 구독 주소 → /sub/trip/{tripId}
        messaging.convertAndSend("/sub/trip/" + tripId, msg);
    }

    /** payload 없는 단순 이벤트용 오버로드 */
    public void publish(Long tripId, String type, Long targetId, String nickname) {
        publish(tripId, type, targetId, nickname, new HashMap<>());
    }

    /** Map.of() 없이 builder 패턴으로 payload 구성하는 헬퍼 */
    public static Map<String, Object> payload(Object... keyValues) {
        Map<String, Object> map = new HashMap<>();
        for (int i = 0; i + 1 < keyValues.length; i += 2) {
            map.put((String) keyValues[i], keyValues[i + 1]);
        }
        return map;
    }
}
