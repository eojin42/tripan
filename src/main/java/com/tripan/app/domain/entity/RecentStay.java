package com.tripan.app.domain.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

// ═══════════════════════════════════════════════════════
//  RecentStay  –  최근 본 숙소 (recent_stay)
//
//  DDL (Oracle):
//  CREATE TABLE recent_stay (
//      recent_stay_id  NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
//      member_id       NUMBER        NOT NULL,
//      place_id        NUMBER        NOT NULL,           -- place.place_id (숙소는 accommodation.place_id와 동일)
//      viewed_at       TIMESTAMP     DEFAULT SYSTIMESTAMP,
//      CONSTRAINT uq_recent_stay UNIQUE (member_id, place_id)  -- 중복 방지, 재방문 시 viewed_at만 갱신
//  );
// ═══════════════════════════════════════════════════════
@Entity
@Table(name = "recent_stay",
    uniqueConstraints = @UniqueConstraint(
        name = "uq_recent_stay", columnNames = {"member_id", "place_id"}
    ),
    indexes = @Index(name = "idx_recent_stay_member", columnList = "member_id")
)
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor @Builder
public class RecentStay {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "recent_stay_id", nullable = false)
    private Long recentStayId;

    @Column(name = "member_id", nullable = false)
    private Long memberId;

    // place.place_id = accommodation.place_id 동일 구조
    @Column(name = "place_id", nullable = false)
    private Long placeId;

    @Column(name = "viewed_at", nullable = false)
    private LocalDateTime viewedAt = LocalDateTime.now();
}
