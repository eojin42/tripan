package com.tripan.app.websocket;

import lombok.*;
import java.util.Map;


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
