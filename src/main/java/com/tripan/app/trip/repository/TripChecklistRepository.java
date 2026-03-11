package com.tripan.app.trip.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.transaction.annotation.Transactional;

import com.tripan.app.trip.domain.entity.TripChecklist;

public interface TripChecklistRepository extends JpaRepository<TripChecklist, Long> {
	// 원본 여행 체크리스트 긁어오기 
	List<TripChecklist> findByTripId(Long tripId);
	
    // 체크박스 클릭 시 0(미완료) <-> 1(완료) 상태 변경 (Update)
    @Modifying
    @Transactional
    @Query("UPDATE TripChecklist c SET c.isChecked = :status WHERE c.checklistId = :checklistId")
    void updateCheckStatus(@Param("checklistId") Long checklistId, @Param("status") Integer status);
    
    // 담당자 지정 
    @Modifying
    @Transactional
    @Query("UPDATE TripChecklist c SET c.checkManager = :manager WHERE c.checklistId = :checklistId")
    void updateCheckManager(@Param("checklistId") Long checklistId, @Param("manager") String manager);
}