package com.tripan.app.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;
import java.util.Map;

@Mapper
public interface VoteMapper {

    List<Map<String, Object>> selectVotesByTripId(@Param("tripId") Long tripId);

    int insertVote(com.tripan.app.trip.domain.entity.Vote vote);

    int insertCandidate(com.tripan.app.trip.domain.entity.VoteCandidate candidate);
    
    int existsVoteRecord(
        @Param("voteId")   Long voteId,
        @Param("memberId") Long memberId
    );

    void insertVoteRecord(
        @Param("voteId")      Long voteId,
        @Param("candidateId") Long candidateId,
        @Param("memberId")    Long memberId
    );

    void deleteVote(
        @Param("voteId") Long voteId,
        @Param("tripId") Long tripId
    );
}
