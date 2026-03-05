package com.tripan.app.trip.domian.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "vote")
@Getter @Setter
public class Vote {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "vote_id")
    private Long voteId; // 투표 PK

    @Column(name = "trip_id", nullable = false)
    private Long tripId; // 여행 ID (FK)

    @Column(name = "title", nullable = false, length = 200)
    private String title; // 투표 제목 (예: 저녁 메뉴 결정)
}