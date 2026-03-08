package com.tripan.app.admin.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.tripan.app.domain.entity.MemberStatus;

@Repository
public interface MemberStatusManageRepository extends JpaRepository<MemberStatus, Long> {
	
}