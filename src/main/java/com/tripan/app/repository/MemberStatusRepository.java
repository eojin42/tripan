package com.tripan.app.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.tripan.app.domain.entity.MemberStatus;

public interface MemberStatusRepository extends JpaRepository<MemberStatus, Long>{

}
