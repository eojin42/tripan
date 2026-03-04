package com.tripan.app.admin.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.tripan.app.admin.domain.entity.Member1;

public interface MemberRepository extends JpaRepository<Member1, Long>{

}
