package com.tripan.app.admin.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.tripan.app.admin.domain.entity.Member1;
import com.tripan.app.admin.domain.entity.Member2;

public interface Member2ManageRepository extends JpaRepository<Member2, Long> {
    Optional<Member2> findByMember1(Member1 member1);
}
