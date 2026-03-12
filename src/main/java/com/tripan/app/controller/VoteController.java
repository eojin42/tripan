package com.tripan.app.controller;

import com.tripan.app.mapper.VoteMapper;
import com.tripan.app.security.CustomUserDetails;
import com.tripan.app.trip.domain.entity.Vote;
import com.tripan.app.trip.domain.entity.VoteCandidate;
import com.tripan.app.websocket.WorkspaceEventPublisher;
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

    private final VoteMapper             voteMapper;
    private final WorkspaceEventPublisher wsPublisher;

    @GetMapping
    public List<Map<String, Object>> getVotes(@PathVariable("tripId") Long tripId) {
        return voteMapper.selectVotesByTripId(tripId);
    }

    @PostMapping
    public ResponseEntity<Map<String, Object>> createVote(
            @PathVariable("tripId") Long tripId,
            @RequestBody Map<String, Object> body,
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        String title = (String) body.get("title");
        @SuppressWarnings("unchecked")
        List<String> candidates = (List<String>) body.get("candidates");
        
        if (title == null || title.isBlank())
            return ResponseEntity.ok(Map.of("success", false, "message", "투표 제목이 필요합니다"));
        if (candidates == null || candidates.size() < 2)
            return ResponseEntity.ok(Map.of("success", false, "message", "후보지가 2개 이상 필요합니다"));

        Vote vote = new Vote();
        vote.setTripId(tripId); vote.setTitle(title);
        voteMapper.insertVote(vote);
        Long voteId = vote.getVoteId();
        
        for (String c : candidates) {
            if (c != null && !c.isBlank()) {
                VoteCandidate vc = new VoteCandidate();
                vc.setVoteId(voteId); vc.setCandidateName(c);
                voteMapper.insertCandidate(vc);
            }
        }
        String nick = userDetails != null ? userDetails.getMember().getNickname() : "멤버";
        wsPublisher.publish(tripId, "VOTE_CREATED", voteId, nick,
                WorkspaceEventPublisher.payload("title", title));
        return ResponseEntity.ok(Map.of("success", true, "voteId", voteId));
    }

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
            return ResponseEntity.ok(Map.of("success", false, "message", "이미 투표했어요"));

        Long candidateId = ((Number) body.get("candidateId")).longValue();
        voteMapper.insertVoteRecord(voteId, candidateId, memberId);

        wsPublisher.publish(tripId, "VOTE_CASTED", voteId,
                userDetails.getMember().getNickname(),
                WorkspaceEventPublisher.payload("candidateId", candidateId));
        return ResponseEntity.ok(Map.of("success", true));
    }

    @DeleteMapping("/{voteId}")
    public ResponseEntity<Map<String, Object>> deleteVote(
            @PathVariable("tripId") Long tripId,
            @PathVariable("voteId") Long voteId,
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        voteMapper.deleteVote(voteId, tripId);
        String nick = userDetails != null ? userDetails.getMember().getNickname() : "멤버";
        wsPublisher.publish(tripId, "VOTE_DELETED", voteId, nick);
        return ResponseEntity.ok(Map.of("success", true));
    }
}
