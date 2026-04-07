package com.tripan.app.admin.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.tripan.app.domain.entity.MemberStatus;

public interface MemberDormantRepository extends JpaRepository<MemberStatus, Long>{

}
