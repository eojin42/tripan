package com.tripan.app.trip.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.tripan.app.trip.domian.entity.Expense;

public interface ExpenseRepository extends JpaRepository<Expense, Long> {

    // 내부 계산용: 특정 여행(tripId)에서 발생한 모든 지출 내역 조회
    List<Expense> findByTripId(Long tripId);
}