package com.tripan.app.domain.dto;

import java.time.LocalDateTime;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class FollowDto {

    private Long   memberId;
    private String nickname;
    private String profileImage;
    private LocalDateTime followAt;
    private boolean isFollowingBack;    // 맞팔 여부
}
