package com.tripan.app.trip.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.tripan.app.trip.domian.entity.Vote;

// 투표 안건 생성 
// ex) 오늘 저녁 뭐먹을까요? 
public interface VoteRepository extends JpaRepository<Vote, Long> {

}