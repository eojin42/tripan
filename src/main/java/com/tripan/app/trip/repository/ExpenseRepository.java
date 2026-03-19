package com.tripan.app.trip.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.tripan.app.trip.domain.entity.Expense;

public interface ExpenseRepository extends JpaRepository<Expense, Long> {

    /**
     * 특정 여행의 모든 지출 조회 (최신순)
     */
    List<Expense> findByTripIdOrderByExpenseDateDesc(Long tripId);

    /**
     * 특정 여행의 특정 카테고리 지출 조회
     */
    List<Expense> findByTripIdAndCategory(Long tripId, String category);

    /**
     * 특정 여행의 지출 + 참여자 한번에 패치 (N+1 방지)
     */
    @Query("""
        SELECT DISTINCT e FROM Expense e
        LEFT JOIN FETCH e.participants ep
        WHERE e.tripId = :tripId
        ORDER BY e.expenseDate DESC
    """)
    List<Expense> findAllWithParticipantsByTripId(@Param("tripId") Long tripId);

    /**
     * 지출 단건 + 참여자 패치 조회
     */
    @Query("""
        SELECT e FROM Expense e
        LEFT JOIN FETCH e.participants ep
        WHERE e.expenseId = :expenseId
    """)
    Optional<Expense> findWithParticipantsById(@Param("expenseId") Long expenseId);

    /**
     * 특정 여행에서 특정 멤버가 결제한 지출 목록
     */
    List<Expense> findByTripIdAndPayerId(Long tripId, Long payerId);

    /**
     * 특정 여행의 총 지출 합계
     */
    @Query("""
        SELECT COALESCE(SUM(e.amount), 0)
        FROM Expense e
        WHERE e.tripId = :tripId
    """)
    java.math.BigDecimal sumAmountByTripId(@Param("tripId") Long tripId);

    /**
     * 카테고리별 지출 합계
     */
    @Query("""
        SELECT e.category, SUM(e.amount)
        FROM Expense e
        WHERE e.tripId = :tripId
        GROUP BY e.category
        ORDER BY SUM(e.amount) DESC
    """)
    List<Object[]> sumAmountGroupByCategory(@Param("tripId") Long tripId);

    /**
     * 여행 ID로 지출 존재 여부 확인
     */
    boolean existsByTripId(Long tripId);

    /**
     * 특정 여행의 지출 전체 삭제 (여행 삭제 시 cascade 대용)
     */
    void deleteByTripId(Long tripId);
}

