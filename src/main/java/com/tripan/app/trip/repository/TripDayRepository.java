package com.tripan.app.trip.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.tripan.app.trip.domain.entity.TripDay;

// 일차 관리 (day1, day2...) 
public interface TripDayRepository extends JpaRepository<TripDay, Long> {
    
	// 여행 ID로 조회하되, 순서대로 가져오기
    List<TripDay> findByTripIdOrderByDayNumberAsc(Long tripId);

    // 수정 시 일수가 줄어들면 특정 순서 이후의 데이터 삭제
    void deleteByTripIdAndDayNumberGreaterThan(Long tripId, Integer dayNumber);
    
    // 여행 ID에 해당하는 모든 일차 삭제(담아오기)
    void deleteByTripId(Long tripId);
}