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
}
