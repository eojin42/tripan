package com.tripan.app.repository;

import com.tripan.app.admin.domain.entity.Member1;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.transaction.annotation.Transactional;

public interface MemberRepository extends JpaRepository<Member1, Long> {

	// 패스워드 변경
    @Modifying
    @Transactional
    @Query("UPDATE Member1 m SET m.password = :password WHERE m.id = :memberId")
    int updatePassword(@Param("memberId") Long memberId,
                       @Param("password") String password);
	
    // 로그인 실패 횟수 증가
    @Modifying
    @Transactional
    @Query("UPDATE Member1 m SET m.failureCnt = m.failureCnt + 1 WHERE m.loginId = :loginId")
    int incrementFailureCount(@Param("loginId") String loginId);

    // 로그인 성공 시 실패 횟수 초기화
    @Modifying
    @Transactional
    @Query("UPDATE Member1 m SET m.failureCnt = 0 WHERE m.loginId = :loginId")
    int resetFailureCount(@Param("loginId") String loginId);

    // 계정 상태 변경 (활성/비활성)
    @Modifying
    @Transactional
    @Query("UPDATE Member1 m SET m.status = :status WHERE m.id = :memberId")
    int updateStatus(@Param("memberId") Long memberId, @Param("status") Integer status);
}