package com.tripan.app.repository;

import com.tripan.app.domain.entity.PlaceReview;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.transaction.annotation.Transactional;

public interface PlaceReviewRepository extends JpaRepository<PlaceReview, Long> {

    // 리뷰 삭제 (본인 것만)
    @Transactional
    int deleteByReviewIdAndMemberId(Long reviewId, Long memberId);

    // 회원 탈퇴 시 전체 삭제
    @Transactional
    void deleteAllByMemberId(Long memberId);
}