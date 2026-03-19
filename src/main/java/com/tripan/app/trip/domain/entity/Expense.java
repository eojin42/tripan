package com.tripan.app.trip.domain.entity;


import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * 지출 원본 저장 테이블
 * 누가 얼마를 결제했는지 저장
 */
@Entity
@Table(name = "expense")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Expense {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "expense_id")
    private Long expenseId;

    /** 어떤 여행의 지출인지 (trip.trip_id FK) */
    @Column(name = "trip_id", nullable = false)
    private Long tripId;

    /** 실제 결제한 사람 (member1.member_id FK) */
    @Column(name = "payer_id", nullable = false)
    private Long payerId;

    /**
     * 지출 카테고리
     * FOOD / ACCOMMODATION / TRANSPORT / TOUR / CAFE / SHOPPING / ETC
     */
    @Column(name = "category", nullable = false, length = 50)
    private String category;

    /** 총 결제 금액 */
    @Column(name = "amount", nullable = false, precision = 12, scale = 2)
    private BigDecimal amount;

    /** 지출명 / 지출 내용 (예: 삼겹살, 택시비) */
    @Column(name = "description", length = 255)
    private String description;

    /** 실제 지출 날짜 */
    @Column(name = "expense_date", nullable = false)
    private LocalDate expenseDate;

    /** 영수증 이미지 경로 (선택값) */
    @Column(name = "receipt_url", length = 255)
    private String receiptUrl;

    /** 등록 시각 */
    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    /** 결제 수단 (카드 / 현금 / 계좌이체)(선택값) */
    @Column(name = "payment_type", length = 50)
    private String paymentType;

    /** 추가 설명 (선택값) */
    @Lob
    @Column(name = "memo")
    private String memo;

    /** 이 지출을 나눠서 부담하는 참여자 목록 */
    @OneToMany(mappedBy = "expense", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    @Builder.Default
    private List<ExpenseParticipant> participants = new ArrayList<>();
}
