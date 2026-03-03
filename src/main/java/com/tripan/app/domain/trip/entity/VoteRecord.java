package com.tripan.app.domain.trip.entity;

import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(
    name = "vote_record",
    uniqueConstraints = {
        // 한 사람이 한 투표 항목에 중복 투표하는 것 방지
        @UniqueConstraint(name = "uk_vote_member", columnNames = {"vote_id", "member_id"})
    }
)
@Getter @Setter
public class VoteRecord {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "record_id")
    private Long recordId;

    @Column(name = "vote_id", nullable = false) //  어떤 투표에 참여했는지 바로 알기 위함
    private Long voteId;

    @Column(name = "candidate_id", nullable = false)
    private Long candidateId;

    @Column(name = "member_id", nullable = false) 
    private Long memberId;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now();
}