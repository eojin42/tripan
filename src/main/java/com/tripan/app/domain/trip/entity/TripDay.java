package com.tripan.app.domain.trip.entity;

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

    @Column(name = "trip_date", nullable = false)
    private LocalDateTime tripDate; // 해당 일자의 실제 날짜

    @Lob
    private String memo; // 해당 일자의 메모
}
