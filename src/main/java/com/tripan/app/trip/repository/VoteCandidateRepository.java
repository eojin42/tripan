package com.tripan.app.trip.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.tripan.app.trip.domain.entity.VoteCandidate;

// 투표 후보 등록
// ex) 회, 고기, 치킨 등록 
public interface VoteCandidateRepository extends JpaRepository<VoteCandidate, Long> {
}