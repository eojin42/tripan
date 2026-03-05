package com.tripan.app.admin.repository;

import com.tripan.app.admin.domain.entity.MemberStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface MemberStatusManageRepository extends JpaRepository<MemberStatus, Long> {
	
}