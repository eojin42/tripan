package com.tripan.app.repository;

import com.tripan.app.domain.entity.Follow;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.transaction.annotation.Transactional;

public interface FollowRepository extends JpaRepository<Follow, Long> {

    // 언팔로우 (본인 것만)
    @Transactional
    int deleteByFollowerIdAndFollowingId(Long followerId, Long followingId);

    // 팔로우 여부 확인
    boolean existsByFollowerIdAndFollowingId(Long followerId, Long followingId);

    // 회원 탈퇴 시 전체 삭제
    @Transactional
    void deleteAllByFollowerId(Long followerId);

    @Transactional
    void deleteAllByFollowingId(Long followingId);
}