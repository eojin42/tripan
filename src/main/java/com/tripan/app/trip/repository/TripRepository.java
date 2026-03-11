package com.tripan.app.trip.repository;

import com.tripan.app.trip.domain.entity.Trip;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface TripRepository extends JpaRepository<Trip, Long> {

    Optional<Trip> findByInviteCode(String inviteCode);

    // ── 스케줄러: PLANNING → ONGOING ──
    // 시작일 ≤ 오늘 AND 종료일 ≥ 오늘 AND status = PLANNING
    List<Trip> findByStatusAndStartDateLessThanEqualAndEndDateGreaterThanEqual(
        String status,
        LocalDateTime startDate,
        LocalDateTime endDate
    );

    // ── 스케줄러: ONGOING → COMPLETED ──
    // 종료일 < 오늘 AND status = ONGOING
    List<Trip> findByStatusAndEndDateBefore(String status, LocalDateTime endDate);
}
