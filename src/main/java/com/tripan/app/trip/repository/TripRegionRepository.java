package com.tripan.app.trip.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.tripan.app.trip.domain.entity.TripRegion;

import java.util.List;

public interface TripRegionRepository extends JpaRepository<TripRegion, Long> {
    
    // 특정 여행에 묶인 도시 목록 가져오기
    List<TripRegion> findByTripId(Long tripId);

    // 여행 정보 수정 시 기존 도시 매핑 싹 밀어버릴 때 사용
    void deleteByTripId(Long tripId);
}