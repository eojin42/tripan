package com.tripan.app.domain.trip.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "settlement")
@Getter
@Setter
public class Settlement {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "settlement_id")
    private Long settlementId; // 정산 id 

    @Column(name = "trip_id", nullable = false)
    private Long tripId; // 여행 id

    @Column(name = "amount", precision = 12, scale = 2, nullable = false)
    private BigDecimal amount; // 정산금액

    @Column(name = "status", length = 20, nullable = false)
    private String status; // 상태 // PENDING, COMPLETED 등

    @Column(name = "settled_at")
    private LocalDateTime settledAt; // 정산 완료 일시

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt; // 생성 일시 
}