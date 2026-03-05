package com.tripan.app.admin.repository;

import com.tripan.app.admin.domain.entity.Member3;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface Member3ManageRepository extends JpaRepository<Member3, Long> {
}