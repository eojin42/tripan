package com.tripan.app.trip.repository;

import com.tripan.app.trip.domain.entity.TripMember;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface TripMemberRepository extends JpaRepository<TripMember, Long> {

    Optional<TripMember> findByTripIdAndMemberId(Long tripId, Long memberId);

    boolean existsByTripIdAndMemberId(Long tripId, Long memberId);

    void deleteByTripIdAndMemberId(Long tripId, Long memberId);

    java.util.List<TripMember> findByTripId(Long tripId);

    /** OWNER 찾기 - TripServiceImpl의 알림 발송에 사용 */
    Optional<TripMember> findByTripIdAndRole(Long tripId, String role);

    /**
     * 환영 모달 읽음 처리 (isFirstVisit 0으로)
     * 워크스페이스 첫 진입 후 JS가 호출
     */
    @org.springframework.data.jpa.repository.Modifying
    @org.springframework.transaction.annotation.Transactional
    @org.springframework.data.jpa.repository.Query(
        "UPDATE TripMember tm SET tm.isFirstVisit = 0 " +
        "WHERE tm.tripId = :tripId AND tm.memberId = :memberId")
    void markFirstVisitDone(
        @org.springframework.data.repository.query.Param("tripId") Long tripId,
        @org.springframework.data.repository.query.Param("memberId") Long memberId);
}
