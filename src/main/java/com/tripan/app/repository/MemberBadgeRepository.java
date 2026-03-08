package com.tripan.app.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.transaction.annotation.Transactional;

import com.tripan.app.domain.entity.MemberBadge;

public interface MemberBadgeRepository extends JpaRepository<MemberBadge, Long> {

    // 특정 배지 획득 여부 확인 (중복 지급 방지)
    boolean existsByMemberIdAndBadgeId(Long memberId, Long badgeId);

    // 회원 탈퇴 시 획득 배지 전체 삭제
    void deleteAllByMemberId(Long memberId);

    // 배지 장착은 member2.equipped_badge_id 컬럼 UPDATE
    // JPA로 직접 처리 (member2 엔티티가 없어서 네이티브 쿼리 사용)
    @Modifying
    @Transactional
    @Query(value = "UPDATE member2 SET equipped_badge_id = :badgeId WHERE member_id = :memberId",
           nativeQuery = true)
    int updateEquippedBadge(@Param("memberId") Long memberId,
                            @Param("badgeId")  Long badgeId);

    // 배지 장착 해제 (equipped_badge_id = NULL)
    @Modifying
    @Transactional
    @Query(value = "UPDATE member2 SET equipped_badge_id = NULL WHERE member_id = :memberId",
           nativeQuery = true)
    int clearEquippedBadge(@Param("memberId") Long memberId);
}
