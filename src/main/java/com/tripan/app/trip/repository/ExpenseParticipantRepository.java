package com.tripan.app.trip.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.transaction.annotation.Transactional;

import com.tripan.app.trip.domain.entity.ExpenseParticipant;

public interface ExpenseParticipantRepository extends JpaRepository<ExpenseParticipant, Long> {

    List<ExpenseParticipant> findByExpenseId(Long expenseId);

    @Modifying
    @Transactional
    @Query("UPDATE ExpenseParticipant ep SET ep.isSettled = :isSettled WHERE ep.participantId = :participantId")
    void updateIsSettled(@Param("participantId") Long participantId, @Param("isSettled") Integer isSettled);

    // 정산 완료된 건이 있는지 확인
    boolean existsByExpenseIdAndIsSettled(Long expenseId, Integer isSettled);

    // 지출 삭제 시 연관된 분담 내역을 함께 삭제
    @Modifying
    @Transactional
    @Query("DELETE FROM ExpenseParticipant ep WHERE ep.expenseId = :expenseId")
    void deleteByExpenseId(@Param("expenseId") Long expenseId);
}