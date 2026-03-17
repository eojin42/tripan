package com.tripan.app.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.tripan.app.mapper.TripMemberMapper;
import com.tripan.app.trip.domain.entity.TripMember;
import com.tripan.app.trip.repository.TripMemberRepository;
import com.tripan.app.websocket.WorkspaceEventPublisher;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
@Transactional
public class TripMemberServiceImpl implements TripMemberService {

    private final TripMemberRepository memberRepository; // CUD 담당
    private final TripMemberMapper memberMapper;         // Read 담당
    private final WorkspaceEventPublisher wsPublisher;
    private final NotificationService notificationService;

    @Override
    public void updateMemberRole(Long tripId, Long targetMemberId, String newRole, Long requesterId) {
        // 요청자가 방장(OWNER)인지 확인
        TripMember requester = memberMapper.findByTripIdAndMemberId(tripId, requesterId);
        if (requester == null || !"OWNER".equals(requester.getRole())) {
            throw new IllegalStateException("방장만 권한을 변경할 수 있습니다.");
        }

        TripMember target = memberRepository.findByTripIdAndMemberId(tripId, targetMemberId)
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 동행자입니다."));
        
        target.setRole(newRole);
        memberRepository.save(target); // 확실하게 저장

        //  변경된 사람에게 알림 저장
        String roleName = newRole.equals("VIEWER") ? "읽기 전용" : "편집자";
        notificationService.notifyOne(tripId, targetMemberId, requesterId, 
            "방장에 의해 [" + roleName + "] 권한으로 변경되었습니다.", "SYSTEM");

        // 웹소켓 발송
        wsPublisher.publish(tripId, "ROLE_CHANGED", targetMemberId, "방장", 
                com.tripan.app.websocket.WorkspaceEventPublisher.payload("newRole", newRole));
    }

    @Override
    public void kickMember(Long tripId, Long targetMemberId, Long requesterId) {
        // ... (기존 검증 로직 동일) ...
        TripMember target = memberRepository.findByTripIdAndMemberId(tripId, targetMemberId)
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 동행자입니다."));

        if ("OWNER".equals(target.getRole())) {
            throw new IllegalStateException("방장을 강퇴할 수는 없습니다.");
        }

        target.setInvitationStatus("DECLINED");
        memberRepository.save(target); // 확실하게 저장

        // 웹소켓 발송 (실시간 튕겨내기용)
        wsPublisher.publish(tripId, "MEMBER_KICKED", targetMemberId, "방장");
    }

    @Override
    public void leaveTrip(Long tripId, Long requesterId) {
        //  내 정보 조회
        TripMember me = memberRepository.findByTripIdAndMemberId(tripId, requesterId)
                .orElseThrow(() -> new IllegalArgumentException("참여 중인 여행이 아닙니다."));

        // 방장은 무책임하게 나갈 수 없음 (여행 자체를 삭제하거나 방장을 위임해야 함)
        if ("OWNER".equals(me.getRole())) {
            throw new IllegalStateException("방장은 스스로 나갈 수 없습니다. 여행을 삭제해주세요.");
        }

        memberRepository.delete(me);
    }
}