package com.tripan.app.repository.trip;

import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import com.tripan.app.domain.trip.entity.TripDay;

// 일차 관리 (day1, day2...) 
public interface TripDayRepository extends JpaRepository<TripDay, Long> {
    
    // 담아오기 할 때 원본의 일차들을 긁어오기 위한 용도 (Service 로직용)
    List<TripDay> findByTripId(Long tripId);
}