package com.tripan.app.trip.domain.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "trip_checklist")
@Getter @Setter
public class TripChecklist {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "checklist_id")
    private Long checklistId; // 체크리스트 PK

    @Column(name = "trip_id", nullable = false)
    private Long tripId; // 여행 ID (FK)

    @Column(name = "item_name", nullable = false, length = 100)
    private String itemName; // 준비물 이름

    @Column(name = "category", length = 50)
    private String category; // 카테고리 (서류 & 결제 / 의류 & 용품 / 의약품 / 전자기기 / 기타)

    @Column(name = "is_checked", nullable = false)
    private Integer isChecked = 0; // 체크 여부 (0: 미완료, 1: 완료)

    @Column(name = "check_manager", length = 20)
    private String checkManager; // 담당자 이름 또는 닉네임
}