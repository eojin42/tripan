package com.tripan.app.trip.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.tripan.app.trip.domain.entity.TripScrap;

// 여행 워크스페이스 담아오기(복제)
public interface TripScrapRepository extends JpaRepository<TripScrap, Long> {


}

