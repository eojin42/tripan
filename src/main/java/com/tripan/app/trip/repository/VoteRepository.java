package com.tripan.app.trip.repository;

import com.tripan.app.trip.domain.entity.Vote;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * VoteRepository — 투표 안건 생성/삭제 전용 (JPA)
 * 조회는 VoteMapper(MyBatis)에서 담당
 */
public interface VoteRepository extends JpaRepository<Vote, Long> {

    /** 투표 안건 삭제 (타 여행 투표 삭제 방지를 위해 tripId 함께 검증) */
    void deleteByVoteIdAndTripId(Long voteId, Long tripId);
}
