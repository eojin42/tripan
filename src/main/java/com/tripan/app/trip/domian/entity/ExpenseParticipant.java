package com.tripan.app.trip.domian.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "expense_participant")
@Getter
@Setter
public class ExpenseParticipant { // 지출 분담

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "participant_id")
    private Long participantId; // 분담 기록 ID

    @Column(name = "expense_id", nullable = false)
    private Long expenseId; // 어떤 지출 내역인지 

    @Column(name = "member_id", nullable = false)
    private Long memberId; // 돈을 내야 할 멤버 ID (예: '나' 또는 '어진')

    @Column(name = "share_amount", nullable = false)
    private Integer shareAmount; // 이 멤버가 내야 할 몫 (예: 18500)

    @Column(name = "is_settled", length = 10)
    private String isSettled; // 정산 완료 여부 (Y / N)

}