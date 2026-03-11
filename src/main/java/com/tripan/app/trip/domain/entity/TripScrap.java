package com.tripan.app.trip.domain.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import java.time.LocalDateTime;

@Entity
@Table(
    name = "trip_scrap",
	indexes = {
			// "내가 스크랩한 목록" 조회 속도 향상
	        @Index(name = "idx_trip_scrap_member", columnList = "member_id")
	    }
)
@Getter @Setter
public class TripScrap {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "scrap_id", nullable = false)
    private Long scrapId; // 스크랩 PK

    @Column(name = "trip_id", nullable = false)
    private Long tripId; // 스크랩된 여행 ID

    @Column(name = "member_id", nullable = false)
    private Long memberId; // 스크랩한 사용자 ID

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now(); // 스크랩한 날짜
}