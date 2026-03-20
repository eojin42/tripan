package com.tripan.app.trip.domain.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 최종 정산 결과 저장 테이블
 * 누가 누구에게 얼마를 보내야 하는지 저장
 * ※ 계산 기준 테이블이 아닌, 계산 결과 / 송금 대상 결과를 저장하는 용도
 */
@Entity
@Table(name = "settlement")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Settlement {

	@Id
	@GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "settlement_seq_gen")
	@SequenceGenerator(name = "settlement_seq_gen", sequenceName = "settlement_seq", allocationSize = 1)
	@Column(name = "settlement_id")
	private Long settlementId;

    /** 어떤 여행의 정산인지 (trip.trip_id FK) */
    @Column(name = "trip_id", nullable = false)
    private Long tripId;

    /** 송금해야 하는 금액 */
    @Column(name = "amount", nullable = false, precision = 12, scale = 2)
    private BigDecimal amount;

    /**
     * 정산 상태
     * REQUESTED(송금 요청) / PENDING(대기) / COMPLETED(송금 완료)
     */
    @Column(name = "status", nullable = false, length = 20)
    @Builder.Default
    private String status = "REQUESTED";

    /** 정산 완료 시각 (송금 완료 처리한 시점) */
    @Column(name = "settled_at")
    private LocalDateTime settledAt;

    /** 정산 row 생성 시각 */
    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    /**
     * 돈 받는 사람 (member1.member_id FK)
     * nullable = true : 정산 대상이 확정되지 않은 경우 허용
     */
    @Column(name = "to_member_id")
    private Long toMemberId;

    /**
     * 돈 보내는 사람 (member1.member_id FK)
     * nullable = true : 정산 대상이 확정되지 않은 경우 허용
     */
    @Column(name = "from_member_id")
    private Long fromMemberId;

    /**
     * 어떤 정산 묶음에서 생성된 정산인지 (선택)
     * 총대 정산 / 일괄 정산 등을 그룹으로 묶을 때 사용
     */
    @Column(name = "batch_id")
    private Long batchId;
}
