package com.tripan.app.domain.trip.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import java.time.LocalDateTime;

@Entity
@Table(name = "itinerary_item")
@Getter
@Setter
public class ItineraryItem {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "item_id")
    private Long itemId; // 일정 항목 PK

    @Column(name = "day_id", nullable = false)
    private Long dayId; // 부모 일자 ID

    @Column(name = "trip_place_id")
    private Long tripPlaceId; // 유저 장소 ID (나만의 장소)

    // LexoRank 순서 제어용 문자열 컬럼 (드래그 앤 드롭 동기화용) 
    @Column(name = "visit_order", nullable = false, length = 255) 
    private String visitOrder; // 방문 순서(정렬용) 

    @Column(name = "start_time", length = 8)
    private String startTime; // 시작 시간

    @Column(name = "end_time", length = 8)
    private String endTime; // 종료 시간 
    
    @Column(name = "duration_minutes")
    private Integer durationMinutes; // 예상 소요시간(분) 

    @Column(name = "distance_km")
    private Double distanceKm; // 이전 장소로부터 거리(km) (소수점 2자리까지)
    
    @Lob
    private String memo; // 장소별 세부 메모 그러고보니까 메모는 컬럼네임이 안필요한지?

    @Column(name = "transportation", length = 50)
    private String transportation; // 이동수단 (도보/차/교통)
    
    
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now(); // 추가일시 
  
    
}