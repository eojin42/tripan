package com.tripan.app.trip.domain.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Table(
    name = "vote_record",
    uniqueConstraints = {
        // 한 사람이 한 투표에 중복 투표 방지
        @UniqueConstraint(name = "uk_vote_member", columnNames = {"vote_id", "member_id"})
    }
)
@Getter @Setter
public class VoteRecord {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "record_id")
    private Long recordId;

    @Column(name = "vote_id", nullable = false)
    private Long voteId;

    @Column(name = "candidate_id", nullable = false)
    private Long candidateId;

    @Column(name = "member_id", nullable = false)
    private Long memberId;

    /**
     * 투표한 시각
     * vote_record 테이블에 created_at DATE NOT NULL DEFAULT SYSDATE 컬럼이 이미 존재함
     * → DB DEFAULT 로 자동 세팅되므로 Java 에서 삽입 시 제외해도 되지만
     *   명시적으로 넣어주면 더 안전 (DB DEFAULT 우선)
     */
    @Column(name = "created_at", nullable = false, updatable = false,
            insertable = false)   // ★ insertable=false → DB DEFAULT SYSDATE 에 맡김
    private LocalDateTime createdAt;
}
