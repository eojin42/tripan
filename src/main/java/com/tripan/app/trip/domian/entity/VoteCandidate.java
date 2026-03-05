package com.tripan.app.trip.domian.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "vote_candidate")
@Getter @Setter
public class VoteCandidate {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "candidate_id")
    private Long candidateId;

    @Column(name = "vote_id", nullable = false)
    private Long voteId;

    @Column(name = "place_id") // 장소 기반 투표일 경우 사용
    private Long placeId;

    @Column(name = "candidate_name", length = 200) // 후보지 이름
    private String candidateName;
}