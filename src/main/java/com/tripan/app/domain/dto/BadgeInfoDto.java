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
public class BadgeInfoDto {

    private Long   badgeId;
    private Long   memberBadgeId;
    private String badgeName;
    private String badgeIconUrl;
    private String description;
    private boolean isEarned;           // 획득 여부 (member_badge 존재 여부)
    private boolean isEquipped;         // 장착 여부 (Member2.equippedBadgeId == badgeId)
    private LocalDateTime acquiredAt;
    private String badgeType;
    private String badgeCategory;
}
