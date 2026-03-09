package com.tripan.app.repository;

import com.tripan.app.admin.domain.entity.Member2;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

public interface Member2Repository extends JpaRepository<Member2, Long> {

    // ── 마지막 로그인 시간 갱신 ──────────────────────────────────
    @Modifying
    @Transactional
    @Query("UPDATE Member2 m SET m.lastLoginAt = :now WHERE m.memberId = :memberId")
    int updateLastLoginAt(@Param("memberId") Long memberId,
                          @Param("now") LocalDateTime now);

    // 프로필 수정 (닉네임, 소개, 전화번호, 선호지역)
    @Modifying
    @Transactional
    @Query("UPDATE Member2 m SET " +
           "m.nickname = :nickname, " +
           "m.bio = :bio, " +
           "m.phoneNumber = :phoneNumber, " +
           "m.preferredRegion = :preferredRegion, " +
           "m.updatedAt = CURRENT_TIMESTAMP " +
           "WHERE m.memberId = :memberId")
    int updateProfile(@Param("memberId")       Long memberId,
                      @Param("nickname")       String nickname,
                      @Param("bio")            String bio,
                      @Param("phoneNumber")    String phoneNumber,
                      @Param("preferredRegion") String preferredRegion);

    // 프로필 이미지 변경
    @Modifying
    @Transactional
    @Query("UPDATE Member2 m SET m.profileImage = :profileImage, " +
           "m.updatedAt = CURRENT_TIMESTAMP WHERE m.memberId = :memberId")
    int updateProfileImage(@Param("memberId")     Long memberId,
                           @Param("profileImage") String profileImage);

    // 장착 배지 변경
    @Modifying
    @Transactional
    @Query("UPDATE Member2 m SET m.equippedBadgeId = :badgeId WHERE m.memberId = :memberId")
    int updateEquippedBadge(@Param("memberId") Long memberId,
                            @Param("badgeId")  Long badgeId);

    // 장착 배지 해제
    @Modifying
    @Transactional
    @Query("UPDATE Member2 m SET m.equippedBadgeId = NULL WHERE m.memberId = :memberId")
    int clearEquippedBadge(@Param("memberId") Long memberId);
}