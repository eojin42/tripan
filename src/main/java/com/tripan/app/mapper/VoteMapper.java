package com.tripan.app.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

/**
 * VoteMapper — 투표 조회 전용 (MyBatis)
 *
 * 생성 / 삭제 는 VoteService → Repository(JPA) 에서 처리합니다.
 * 복잡한 JOIN + 서브쿼리가 필요한 조회만 여기에 작성합니다.
 */
@Mapper
public interface VoteMapper {

    /**
     * 투표 목록 조회 (후보지 + 득표수 + 내 투표 기록 포함)
     *
     * @param tripId   여행 ID
     * @param memberId 현재 로그인 유저 ID (미로그인 시 null → myVotedCandidateId = null)
     */
    List<Map<String, Object>> selectVotesByTripId(
            @Param("tripId")   Long tripId,
            @Param("memberId") Long memberId
    );
}
