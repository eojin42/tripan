package com.tripan.app.admin.repository;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import com.tripan.app.admin.domain.entity.Booking;

public interface BookingManageRepository extends JpaRepository<Booking, Long> {
    List<Booking> findByMemberIdOrderByRegDateDesc(Long memberId);
}