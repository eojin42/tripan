package com.tripan.app.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;


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
