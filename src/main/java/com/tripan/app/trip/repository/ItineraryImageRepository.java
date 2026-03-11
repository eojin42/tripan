package com.tripan.app.trip.repository;

import com.tripan.app.trip.domain.entity.ItineraryImage;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;


@Repository
public interface ItineraryImageRepository extends JpaRepository<ItineraryImage, Long> {
}