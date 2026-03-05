package com.tripan.app.trip.domian.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "expense")
@Getter
@Setter
public class Expense { 

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "expense_id")
    private Long expenseId; // 지출 ID 

    @Column(name = "trip_id", nullable = false)
    private Long tripId; // 여행 ID

    @Column(name = "payer_id", nullable = false)
    private Long payerId; // 결제한 사람 (멤버 ID)

    // 카테고리 Enum 처리
    @Enumerated(EnumType.STRING)
    @Column(name = "category", length = 50, nullable = false)
    private ExpenseCategory category; 

    @Column(name = "amount", nullable = false)
    private Integer amount; // 금액 

    @Column(name = "description", length = 255)
    private String description; // 지출 내용 

    @Column(name = "expense_date", nullable = false)
    private LocalDate expenseDate; // 결제일 

    @Column(name = "receipt_url", length = 255)
    private String receiptUrl; // 영수증 이미지 경로

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt; // 등록 일시 

    @Column(name = "payment_type", length = 50)
    private String paymentType; // 지출 수단 (카드/현금/카카오페이 등)

    @Lob
    @Column(name = "memo")
    private String memo; // 메모 

    @Column(name = "is_private", length = 10)
    private String isPrivate; // 나만보기 여부 (Y/N)
}