package com.tripan.app.trip.domain.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import java.time.LocalDateTime;

@Entity
@Table(name = "trip_day")
@Getter @Setter
public class TripDay {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "day_id")
    private Long dayId; // N일차 PK

    @Column(name = "trip_id", nullable = false)
    private Long tripId; // 부모(여행) 일정 ID

    @Column(name = "day_number", nullable = false)
    private Integer dayNumber; // N일차 순서

    @Column(name = "trip_date")
    private LocalDateTime tripDate; // 여행날짜 

    @Lob
    private String memo; // 해당 일자의 메모
}
