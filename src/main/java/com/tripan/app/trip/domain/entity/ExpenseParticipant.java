package com.tripan.app.trip.domain.entity;


import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;

/**
 * 지출별 분담 정보 테이블
 * 이 지출을 누가 얼마 부담해야 하는지 저장 → 실제 정산 계산의 기준
 *
 * [예] 삼겹살 60,000원을 A가 결제, A/B가 먹은 경우
 *   → expense: payer=A, amount=60000
 *   → expense_participant: (A, 30000), (B, 30000)
 */
@Entity
@Table(name = "expense_participant")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ExpenseParticipant {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "participant_id")
    private Long participantId;

    /** 어떤 지출에 대한 분담인지 */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "expense_id", nullable = false)
    private Expense expense;

    /**
     * 이 지출을 부담하는 사람 (member1.member_id FK)
     * 외부 인원(워크스페이스 밖)은 null 허용
     */
    @Column(name = "member_id")
    private Long memberId;

    /**
     * 외부 인원(워크스페이스 밖 참여자)의 이름
     * memberId가 null인 경우 이 값으로 식별
     */
    @Column(name = "nickname", length = 100)
    private String nickname;

    /** 이 사람이 부담해야 하는 금액 */
    @Column(name = "share_amount", nullable = false, precision = 12, scale = 2)
    private BigDecimal shareAmount;
}
