package com.tripan.app.trip.repository;

import com.tripan.app.trip.domain.entity.VoteCandidate;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * VoteCandidateRepository — 후보지 등록/삭제 전용 (JPA)
 * 조회는 VoteMapper(MyBatis)에서 담당
 */
public interface VoteCandidateRepository extends JpaRepository<VoteCandidate, Long> {

    /** 투표 삭제 시 하위 후보지 일괄 삭제 */
    void deleteByVoteId(Long voteId);
}
