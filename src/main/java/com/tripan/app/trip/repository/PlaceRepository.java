package com.tripan.app.trip.repository;

import com.tripan.app.trip.domain.entity.Place;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PlaceRepository extends JpaRepository<Place, Long> {
    //  중복 저장 방지용
    boolean existsById(Long placeId);
}