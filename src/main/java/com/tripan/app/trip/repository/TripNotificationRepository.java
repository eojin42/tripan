package com.tripan.app.trip.repository;

import com.tripan.app.trip.domain.entity.TripNotification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface TripNotificationRepository extends JpaRepository<TripNotification, Long> {
}
