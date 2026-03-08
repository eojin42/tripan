package com.tripan.app.admin.domain.entity;
import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Lob;
import jakarta.persistence.PrePersist;
import jakarta.persistence.SequenceGenerator;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * 배지 달성 조건 타입
 */
enum BadgeConditionType {
    REVIEW_COUNT, // 리뷰 작성 수
    TRIP_COUNT    // 여행 횟수
}

@Entity
@Table(name = "badge")
@Getter @Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@SequenceGenerator(
    name = "BADGE_SEQ_GEN",
    sequenceName = "seq_badge_id",
    initialValue = 1,
    allocationSize = 1
)
public class Badge {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "BADGE_SEQ_GEN")
    @Column(name = "badge_id")
    private Long badgeId;

    @Column(name = "badge_name", nullable = false, length = 20)
    private String badgeName;

    @Lob // CLOB 매핑
    @Column(name = "badge_icon_url")
    private String badgeIconUrl;

    @Enumerated(EnumType.STRING) // Enum 이름을 문자열로 저장
    @Column(name = "condition_type", nullable = false, length = 30)
    private BadgeConditionType conditionType;

    @Column(name = "condition_value", nullable = false)
    private Integer conditionValue;

    @Column(name = "description", length = 255)
    private String description;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @PrePersist // 저장 전 자동으로 현재 시간 세팅
    public void prePersist() {
        this.createdAt = LocalDateTime.now();
    }
}