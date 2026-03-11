package com.tripan.app.trip.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.tripan.app.trip.domain.entity.VoteRecord;

// 투표 기록(완료/결과)
public interface VoteRecordRepository extends JpaRepository<VoteRecord, Long> {

	// 중복 투표 체크
	boolean existsByVoteIdAndMemberId(Long voteId, Long memberId);
    
}