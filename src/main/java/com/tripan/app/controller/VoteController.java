package com.tripan.app.controller;

import com.tripan.app.mapper.VoteMapper;
import com.tripan.app.security.CustomUserDetails; // 💡 조장님 경로 확인!
import com.tripan.app.trip.domain.entity.Vote;
import com.tripan.app.trip.domain.entity.VoteCandidate;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/trip/{tripId}/vote")
@RequiredArgsConstructor
public class VoteController {

    private final VoteMapper voteMapper;

    @GetMapping
    public List<Map<String, Object>> getVotes(@PathVariable("tripId") Long tripId) {
        return voteMapper.selectVotesByTripId(tripId);
    }

    @PostMapping
    public ResponseEntity<Map<String, Object>> createVote(
            @PathVariable("tripId") Long tripId,
            @RequestBody Map<String, Object> body) {
        String title = (String) body.get("title");
        @SuppressWarnings("unchecked")
        List<String> candidates = (List<String>) body.get("candidates");
        
        if (title == null || title.isBlank()) return ResponseEntity.badRequest().body(Map.of("success", false, "message", "투표 제목이 필요합니다"));
        if (candidates == null || candidates.size() < 2) return ResponseEntity.badRequest().body(Map.of("success", false, "message", "후보지가 2개 이상 필요합니다"));

        // ✨ 투표 마스터 생성
        Vote vote = new Vote();
        vote.setTripId(tripId);
        vote.setTitle(title);
        voteMapper.insertVote(vote);
        Long realVoteId = vote.getVoteId(); // 정상적인 PK 획득!

        // ✨ 후보지 생성
        for (String candidate : candidates) {
            if (candidate != null && !candidate.isBlank()) {
                VoteCandidate vc = new VoteCandidate();
                vc.setVoteId(realVoteId);
                vc.setCandidateName(candidate);
                voteMapper.insertCandidate(vc);
            }
        }
        return ResponseEntity.ok(Map.of("success", true, "voteId", realVoteId));
    }

    // ✨ 핵심 수정: 세션 대신 Spring Security 적용!
    @PostMapping("/{voteId}/cast")
    public ResponseEntity<Map<String, Object>> castVote(
            @PathVariable("tripId") Long tripId,
            @PathVariable("voteId") Long voteId,
            @RequestBody Map<String, Object> body,
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        
        if (userDetails == null)
            return ResponseEntity.status(401).body(Map.of("success", false, "message", "로그인이 필요합니다"));

        Long memberId = userDetails.getMember().getMemberId();

        if (voteMapper.existsVoteRecord(voteId, memberId) > 0)
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", "이미 투표했어요"));

        Long candidateId = Long.valueOf(body.get("candidateId").toString());
        voteMapper.insertVoteRecord(voteId, candidateId, memberId);
        return ResponseEntity.ok(Map.of("success", true));
    }

    @DeleteMapping("/{voteId}")
    public ResponseEntity<Map<String, Object>> deleteVote(
            @PathVariable("tripId") Long tripId,
            @PathVariable("voteId") Long voteId) {
        voteMapper.deleteVote(voteId, tripId);
        return ResponseEntity.ok(Map.of("success", true));
    }
}