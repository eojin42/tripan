package com.tripan.app.trip.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.tripan.app.trip.domian.entity.Tag;

import java.util.Optional;

// 태그 사전 관리
public interface TagRepository extends JpaRepository<Tag, Long> {

    // 태그 이름으로 기존 태그 찾기
    // 프론트에서 넘어온 '#제주도'가 이미 DB에 있는지 확인 없으면 save()로 새로 만듬
	Optional<Tag> findByTagName(String tagName);
    
}