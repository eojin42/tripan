package com.tripan.app.trip.domian.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Table(name = "trip")
@Getter @Setter
public class Trip {
	// 주석 써놓고 나중에 지울게염 
	
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY) // 시퀀스 같은거 
    @Column(name = "trip_id")
    private Long tripId; // 일정 PK

    @Column(name = "member_id", nullable = false)
    private Long memberId; // 방장(생성자) ID

    @Column(name = "region_id", nullable = false)
    private Long regionId; // 여행 지역 ID

    @Column(name = "trip_name", nullable = false, length = 200)
    private String tripName; // 여행 제목

    @Column(name = "start_date", nullable = false)
    private LocalDateTime startDate; // 여행 시작일

    @Column(name = "end_date", nullable = false)
    private LocalDateTime endDate; // 여행 종료일

    @Lob // 대용량 CLOB 타입일 때 ㄱㄱ 
    private String description; // 일정 소개글 

    @Column(name = "thumbnail_url", length = 500)
    private String thumbnailUrl; // 썸네일 이미지

    @Column(name = "is_public", nullable = false)
    private Integer isPublic = 0; // 공개 여부 (0: 비공개, 1: 공개)

    @Column(name = "total_budget")
    private Double totalBudget; // 총 예산

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now(); // 생성일
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt; // 수정일 
    
    @Column(name = "status", nullable = false, length = 20)
    private String status = "PLANNING"; // 상태 (PLANNING/ONGOING/COMPLETED)
    
    @Column(name = "scrap_count", nullable = false)
    private Integer scrapCount = 0; // 담아오기(스크랩) 횟수

    @Column(name = "invite_code", length = 50, unique = true) 
    private String inviteCode; // 초대 링크 코드 (UNIQUE)
    
    @Column(name = "original_trip_id")
    private Long originalTripId; // 원본 일정 ID (담아오기 시 계보 추적용) 
    
    @Column(name = "trip_type", length = 30)
    private String tripType; // 여행 유형 (커플/가족/친구 등)

    // 엔티티가 업데이트 될 때 자동으로 수정일(updatedAt) 갱신해 줌 
    @PreUpdate
    public void preUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
}