package com.tripan.app.service;

import com.tripan.app.mapper.VoteMapper;
import com.tripan.app.trip.domain.entity.Vote;
import com.tripan.app.trip.domain.entity.VoteCandidate;
import com.tripan.app.trip.domain.entity.VoteRecord;
import com.tripan.app.trip.repository.VoteCandidateRepository;
import com.tripan.app.trip.repository.VoteRecordRepository;
import com.tripan.app.trip.repository.VoteRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * VoteServiceImpl
 * ─────────────────────────────────────────
 * 조회  → VoteMapper  (MyBatis)
 * CUD   → Repository  (JPA)
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional
public class VoteServiceImpl implements VoteService {

    private final VoteMapper              voteMapper;
    private final VoteRepository          voteRepository;
    private final VoteCandidateRepository voteCandidateRepository;
    private final VoteRecordRepository    voteRecordRepository;
    // ★ 알림 서비스 주입
    private final NotificationService     notificationService;

    // ── 조회 ─────────────────────────────────────────────
    @Override
    @Transactional(readOnly = true)
    public List<Map<String, Object>> getVotes(Long tripId, Long memberId) {
        return voteMapper.selectVotesByTripId(tripId, memberId);
    }

    // ── 생성 ─────────────────────────────────────────────
    @Override
    public Long createVote(Long tripId, String title,
                           List<String> candidates, LocalDateTime deadline) {
        Vote vote = new Vote();
        vote.setTripId(tripId);
        vote.setTitle(title);
        vote.setDeadline(deadline);          // null = 무기한
        voteRepository.save(vote);
        Long voteId = vote.getVoteId();

        for (String name : candidates) {
            if (name == null || name.isBlank()) continue;
            VoteCandidate vc = new VoteCandidate();
            vc.setVoteId(voteId);
            vc.setCandidateName(name);
            voteCandidateRepository.save(vc);
        }

        log.info("[Vote] 생성 tripId={}, voteId={}, 후보={}, 마감={}",
                tripId, voteId, candidates.size(), deadline);
        return voteId;
    }

    // ── 투표 참여 ─────────────────────────────────────────
    @Override
    public void castVote(Long voteId, Long candidateId, Long memberId) {

        // 1) 마감 체크
        Vote vote = voteRepository.findById(voteId)
                .orElseThrow(() -> new IllegalStateException("존재하지 않는 투표예요"));

        if (vote.getDeadline() != null && LocalDateTime.now().isAfter(vote.getDeadline())) {
            throw new IllegalStateException("투표가 마감됐어요");
        }

        // 2) 중복 투표 체크
        if (voteRecordRepository.existsByVoteIdAndMemberId(voteId, memberId)) {
            throw new IllegalStateException("이미 투표하셨어요");
        }

        // 3) 투표 저장
        VoteRecord record = new VoteRecord();
        record.setVoteId(voteId);
        record.setCandidateId(candidateId);
        record.setMemberId(memberId);
        voteRecordRepository.save(record);

        log.info("[Vote] 참여 voteId={}, candidateId={}, memberId={}", voteId, candidateId, memberId);
    }

    // ── 삭제 ─────────────────────────────────────────────
    @Override
    public void deleteVote(Long voteId, Long tripId) {
        voteRecordRepository.deleteByVoteId(voteId);
        voteCandidateRepository.deleteByVoteId(voteId);
        voteRepository.deleteByVoteIdAndTripId(voteId, tripId);
        log.info("[Vote] 삭제 voteId={}, tripId={}", voteId, tripId);
    }

    // ── 제목 조회 (삭제 알림용) ───────────────────────────
    @Override
    @Transactional(readOnly = true)
    public String getVoteTitle(Long voteId) {
        return voteRepository.findById(voteId)
            .map(v -> v.getTitle())
            .orElse("투표");
    }

    // ── ★ 알림 포함 생성 (VoteRestController에서 호출) ─────
    /**
     * 투표 생성 + 알림 저장
     * @param senderMemberId 투표 만든 사람 memberId (본인 제외하고 notifyAll)
     * @param senderNickname 투표 만든 사람 닉네임 (알림 메시지에 포함)
     */
    public Long createVoteWithNotif(Long tripId, String title, List<String> candidates,
                                    LocalDateTime deadline, Long senderMemberId, String senderNickname) {
        Long voteId = createVote(tripId, title, candidates, deadline);

        // ★ 나머지 멤버들에게 알림 저장
        String nick = (senderNickname != null && !senderNickname.isEmpty()) ? senderNickname : "누군가";
        notificationService.notifyAll(tripId, senderMemberId,
            nick + "님이 투표 [" + title + "] 를 만들었어요 🗳️", "VOTE");

        return voteId;
    }

    /**
     * 투표 삭제 + 알림 저장
     */
    public void deleteVoteWithNotif(Long voteId, Long tripId, String voteTitle,
                                    Long senderMemberId, String senderNickname) {
        deleteVote(voteId, tripId);

        String nick = (senderNickname != null && !senderNickname.isEmpty()) ? senderNickname : "누군가";
        notificationService.notifyAll(tripId, senderMemberId,
            nick + "님이 투표 [" + voteTitle + "] 를 삭제했어요 🗑️", "VOTE");
    }
}
