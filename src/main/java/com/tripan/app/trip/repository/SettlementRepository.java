package com.tripan.app.trip.repository;

import java.math.BigDecimal;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.tripan.app.trip.domain.entity.Settlement;

public interface SettlementRepository extends JpaRepository<Settlement, Long> {

    /**
     * 특정 여행의 전체 정산 조회
     */
    List<Settlement> findByTripId(Long tripId);

    /**
     * 특정 여행의 미완료(PENDING) 정산 조회
     */
    List<Settlement> findByTripIdAndStatus(Long tripId, String status);

    /**
     * 특정 배치의 정산 목록 조회 (일괄 정산 그룹)
     */
    List<Settlement> findByBatchId(Long batchId);

    /**
     * 내가 보내야 할 정산 목록 (특정 여행 기준)
     */
    List<Settlement> findByTripIdAndFromMemberId(Long tripId, Long fromMemberId);

    /**
     * 내가 받아야 할 정산 목록 (특정 여행 기준)
     */
    List<Settlement> findByTripIdAndToMemberId(Long tripId, Long toMemberId);

    /**
     * 내가 관련된 정산 전체 조회 (보내는 것 + 받는 것 모두)
     */
    @Query("""
        SELECT s FROM Settlement s
        WHERE s.tripId = :tripId
          AND (s.fromMemberId = :memberId OR s.toMemberId = :memberId)
        ORDER BY s.createdAt DESC
    """)
    List<Settlement> findByTripIdAndMember(
            @Param("tripId") Long tripId,
            @Param("memberId") Long memberId
    );

    /**
     * 특정 여행에서 내가 받아야 할 총액 (PENDING 기준)
     */
    @Query("""
        SELECT COALESCE(SUM(s.amount), 0)
        FROM Settlement s
        WHERE s.tripId = :tripId
          AND s.toMemberId = :memberId
          AND s.status = 'PENDING'
    """)
    BigDecimal sumAmountToReceive(
            @Param("tripId") Long tripId,
            @Param("memberId") Long memberId
    );

    /**
     * 특정 여행에서 내가 보내야 할 총액 (PENDING 기준)
     */
    @Query("""
        SELECT COALESCE(SUM(s.amount), 0)
        FROM Settlement s
        WHERE s.tripId = :tripId
          AND s.fromMemberId = :memberId
          AND s.status = 'PENDING'
    """)
    BigDecimal sumAmountToSend(
            @Param("tripId") Long tripId,
            @Param("memberId") Long memberId
    );

    /**
     * 특정 여행의 정산이 모두 완료됐는지 확인
     */
    @Query("""
        SELECT COUNT(s) = 0
        FROM Settlement s
        WHERE s.tripId = :tripId
          AND s.status = 'PENDING'
    """)
    boolean isAllSettled(@Param("tripId") Long tripId);

    /**
     * 특정 배치 정산 일괄 완료 처리
     */
    @Modifying
    @Query("""
        UPDATE Settlement s
        SET s.status = 'COMPLETED', s.settledAt = CURRENT_TIMESTAMP
        WHERE s.batchId = :batchId
          AND s.status = 'PENDING'
    """)
    int completeBatch(@Param("batchId") Long batchId);

    /**
     * 특정 여행의 기존 정산 전체 삭제 (재정산 시 초기화)
     */
    @Modifying
    void deleteByTripId(Long tripId);

    /**
     * 가장 최근 사용된 batchId + 1 반환 (배치 ID 생성용)
     */
    @Query("SELECT COALESCE(MAX(s.batchId), 0) + 1 FROM Settlement s")
    Long generateNextBatchId();
}
