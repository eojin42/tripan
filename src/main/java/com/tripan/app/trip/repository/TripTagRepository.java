package com.tripan.app.trip.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.transaction.annotation.Transactional;

import com.tripan.app.trip.domain.entity.TripTag;

import java.util.List;

// 여행-태그 매핑 관리
public interface TripTagRepository extends JpaRepository<TripTag, Long> {

    // [담아오기 로직용] 원본 여행의 태그 매핑 정보 가져오기
    List<TripTag> findByTripId(Long tripId);

    // 프론트에서 특정 태그 하나만 X 눌러서 지울 때
    @Modifying
    @Transactional
    @Query("DELETE FROM TripTag t WHERE t.tripId = :tripId AND t.tagId = :tagId")
    void deleteByTripIdAndTagId(@Param("tripId") Long tripId, @Param("tagId") Long tagId);

    // 글 수정 완료 시, 기존 태그 싹 밀기
    // 기존 매핑을 싹 다 날리고 프론트에서 받은 걸 새로 saveAll()
    @Modifying
    @Transactional
    @Query("DELETE FROM TripTag t WHERE t.tripId = :tripId")
    void deleteByTripId(@Param("tripId") Long tripId);
}