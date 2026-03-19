package com.tripan.app.trip.repository;

import java.math.BigDecimal;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.tripan.app.trip.domain.entity.ExpenseParticipant;

public interface ExpenseParticipantRepository extends JpaRepository<ExpenseParticipant, Long> {

    /**
     * 특정 지출의 모든 분담자 조회
     */
    List<ExpenseParticipant> findByExpense_ExpenseId(Long expenseId);

    /**
     * 특정 멤버가 특정 지출에서 부담하는 금액 조회
     */
    @Query("""
        SELECT ep FROM ExpenseParticipant ep
        WHERE ep.expense.expenseId = :expenseId
          AND ep.memberId = :memberId
    """)
    java.util.Optional<ExpenseParticipant> findByExpenseIdAndMemberId(
            @Param("expenseId") Long expenseId,
            @Param("memberId") Long memberId
    );

    /**
     * 특정 여행에서 멤버별 부담 합계
     * (정산 계산의 핵심 쿼리)
     * 반환: [memberId, totalShareAmount]
     */
    @Query("""
        SELECT ep.memberId, SUM(ep.shareAmount)
        FROM ExpenseParticipant ep
        JOIN ep.expense e
        WHERE e.tripId = :tripId
        GROUP BY ep.memberId
    """)
    List<Object[]> sumShareAmountByMemberForTrip(@Param("tripId") Long tripId);

    /**
     * 특정 지출의 분담자 전체 삭제 (지출 수정 시 전체 교체용)
     */
    @Modifying
    @Query("""
        DELETE FROM ExpenseParticipant ep
        WHERE ep.expense.expenseId = :expenseId
    """)
    void deleteByExpenseId(@Param("expenseId") Long expenseId);

    /**
     * 특정 여행에서 특정 멤버가 참여한 지출 목록의 participant 조회
     */
    @Query("""
        SELECT ep FROM ExpenseParticipant ep
        JOIN ep.expense e
        WHERE e.tripId = :tripId
          AND ep.memberId = :memberId
    """)
    List<ExpenseParticipant> findByTripIdAndMemberId(
            @Param("tripId") Long tripId,
            @Param("memberId") Long memberId
    );

    /**
     * 특정 지출의 분담 금액 합계 (expense.amount와 일치 검증용)
     */
    @Query("""
        SELECT COALESCE(SUM(ep.shareAmount), 0)
        FROM ExpenseParticipant ep
        WHERE ep.expense.expenseId = :expenseId
    """)
    BigDecimal sumShareAmountByExpenseId(@Param("expenseId") Long expenseId);
}
