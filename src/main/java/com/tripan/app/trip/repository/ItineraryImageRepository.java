package com.tripan.app.trip.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.tripan.app.trip.domain.entity.ItineraryImage;

public interface ItineraryImageRepository extends JpaRepository<ItineraryImage, Long> {

    List<ItineraryImage> findByItemId(Long itemId);

    @Modifying
    @Query("DELETE FROM ItineraryImage i WHERE i.itemId = :itemId")
    void deleteByItemId(@Param("itemId") Long itemId);
}
