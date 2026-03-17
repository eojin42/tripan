package com.tripan.app.trip.domain.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Table(name = "vote")
@Getter @Setter
public class Vote {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "vote_id")
    private Long voteId;

    @Column(name = "trip_id", nullable = false)
    private Long tripId;

    @Column(name = "title", nullable = false, length = 200)
    private String title;

    /**
     * 투표 생성일시
     * → ALTER TABLE vote ADD created_at DATE DEFAULT SYSDATE NOT NULL; 실행 후 활성화
     * → DB DEFAULT SYSDATE 가 있으므로 Java 에서 세팅 안 해도 되지만 명시적으로 넣어줌
     */
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now();

    /**
     * 투표 마감일시 — NULL = 무기한 진행
     * → ALTER TABLE vote ADD deadline DATE DEFAULT NULL; 실행 후 활성화
     * → NULL 이면 마감 없이 계속 투표 가능
     */
    @Column(name = "deadline")
    private LocalDateTime deadline;
}
