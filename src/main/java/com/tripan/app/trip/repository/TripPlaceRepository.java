package com.tripan.app.trip.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.tripan.app.trip.domain.entity.TripPlace;

import java.util.Optional;

public interface TripPlaceRepository extends JpaRepository<TripPlace, Long> {

    // 카카오맵 API 고유 ID로 우리 DB에 이미 등록된 장소인지 검사
    Optional<TripPlace> findByApiPlaceId(String apiPlaceId);
    
}