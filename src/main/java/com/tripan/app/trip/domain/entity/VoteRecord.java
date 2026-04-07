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

    @Column(name = "created_at", nullable = false, updatable = false,
            insertable = false)   // ★ insertable=false → DB DEFAULT SYSDATE 에 맡김
    private LocalDateTime createdAt;
}
