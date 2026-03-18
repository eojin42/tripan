package com.tripan.app.service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * VoteService
 * ─────────────────────────────────────────
 * 원칙:
 *   조회 → VoteMapper (MyBatis — 복잡한 JOIN + 서브쿼리)
 *   CUD  → Repository (JPA    — 단순 엔티티 저장/삭제)
 */
public interface VoteService {

    /** 투표 목록 조회 (후보지 + 득표수 + 내 투표 기록 + 마감 여부 포함) */
    List<Map<String, Object>> getVotes(Long tripId, Long memberId);

    /**
     * 투표 생성
     * @param deadline  마감일시 — null 이면 무기한
     */
    Long createVote(Long tripId, String title, List<String> candidates, LocalDateTime deadline);

    /**
     * 투표 참여
     * @throws IllegalStateException "이미 투표하셨어요" | "투표가 마감됐어요"
     */
    void castVote(Long voteId, Long candidateId, Long memberId);

    /** 투표 삭제 */
    void deleteVote(Long voteId, Long tripId);

    /** 투표 제목 조회 (삭제 알림 메시지용) */
    String getVoteTitle(Long voteId);
}
