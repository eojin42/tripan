package com.tripan.app.trip.repository;

import com.tripan.app.trip.domain.entity.Expense;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface ExpenseRepository extends JpaRepository<Expense, Long> {

    /** 가계부 목록 - 날짜 역순 */
    List<Expense> findByTripIdOrderByExpenseDateDesc(Long tripId);

    /** 정산 계산용 */
    List<Expense> findByTripId(Long tripId);
}
