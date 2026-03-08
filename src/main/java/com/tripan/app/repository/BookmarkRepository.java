package com.tripan.app.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.tripan.app.domain.entity.Bookmark;


public interface BookmarkRepository extends JpaRepository<Bookmark, Long> {

    // 찜 여부 확인 (중복 등록 방지용)
    // ex) bookmarkRepository.existsByMemberIdAndPlaceId(memberId, placeId)
    boolean existsByMemberIdAndPlaceId(Long memberId, Long placeId);

    // 찜 해제 (본인 것만 삭제 - 보안)
    // 반환값: 삭제된 행 수 (0이면 본인 것 아님)
    int deleteByBookmarkIdAndMemberId(Long bookmarkId, Long memberId);

    // 회원 탈퇴 시 해당 회원 찜 전체 삭제
    void deleteAllByMemberId(Long memberId);
}
