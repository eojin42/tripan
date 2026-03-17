package com.tripan.app.trip.repository;

import com.tripan.app.trip.domain.entity.VoteRecord;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * VoteRecordRepository — 투표 기록 저장/삭제 전용 (JPA)
 * 조회는 VoteMapper(MyBatis)에서 담당
 */
public interface VoteRecordRepository extends JpaRepository<VoteRecord, Long> {

    /** 중복 투표 체크 */
    boolean existsByVoteIdAndMemberId(Long voteId, Long memberId);

    /** 투표 삭제 시 하위 기록 일괄 삭제 */
    void deleteByVoteId(Long voteId);
}
