package com.tripan.app.trip.domian.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(
    name = "trip_tag",
    uniqueConstraints = {
        // 하나의 여행에 똑같은 태그가 두 번 달리지 않게 방지
        @UniqueConstraint(columnNames = {"tag_id", "trip_id"})
    }
)
@Getter @Setter
public class TripTag { // 태그-여행 매핑

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "trip_tag_id")
    private Long tripTagId; // 매핑 PK

    @Column(name = "tag_id", nullable = false)
    private Long tagId; // 태그 ID (FK)

    @Column(name = "trip_id", nullable = false)
    private Long tripId; // 여행 ID (FK)
}