package com.tripan.app.trip.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.transaction.annotation.Transactional;

import com.tripan.app.trip.domian.entity.ExpenseParticipant;

public interface ExpenseParticipantRepository extends JpaRepository<ExpenseParticipant, Long> {

    // 내부 계산용: 특정 지출 건(expenseId)에 엮인 분담자 목록 조회
    List<ExpenseParticipant> findByExpenseId(Long expenseId);

    // 단건 업데이트: 개별 분담 내역 정산 완료 처리 (0 -> 1)
    @Modifying
    @Transactional
    @Query("UPDATE ExpenseParticipant ep SET ep.isSettled = :isSettled WHERE ep.participantId = :participantId")
    void updateIsSettled(@Param("participantId") Long participantId, @Param("isSettled") Integer isSettled);
}