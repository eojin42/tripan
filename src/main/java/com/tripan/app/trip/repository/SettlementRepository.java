package com.tripan.app.trip.repository;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.transaction.annotation.Transactional;

import com.tripan.app.trip.domain.entity.Settlement;

public interface SettlementRepository extends JpaRepository<Settlement, Long> {

    // 내부 계산용: 특정 여행(tripId)의 최종 정산서 목록 조회
    List<Settlement> findByTripId(Long tripId);

    // 단건 업데이트: 정산서 상태 변경(PENDING -> COMPLETED) 및 처리 시간(settledAt) 기록
    @Modifying
    @Transactional
    @Query("UPDATE Settlement s SET s.status = :status, s.settledAt = :settledAt WHERE s.settlementId = :settlementId")
    void updateStatusAndSettledAt(@Param("settlementId") Long settlementId, @Param("status") String status, @Param("settledAt") LocalDateTime settledAt);
}