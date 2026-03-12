package com.tripan.app.mapper;

import com.tripan.app.trip.domain.entity.Vote;
import com.tripan.app.trip.domain.entity.VoteCandidate;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;
import java.util.Map;

@Mapper
public interface VoteMapper {

    List<Map<String, Object>> selectVotesByTripId(@Param("tripId") Long tripId);

    /** Controller에서 Vote 엔티티로 호출 → INSERT 후 voteId PK 세팅 */
    void insertVote(Vote vote);

    /** Controller에서 VoteCandidate 엔티티로 호출 → INSERT 후 candidateId PK 세팅 */
    void insertCandidate(VoteCandidate vc);

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
