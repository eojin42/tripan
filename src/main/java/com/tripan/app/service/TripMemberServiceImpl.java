package com.tripan.app.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.tripan.app.trip.domain.entity.TripMember;
import com.tripan.app.trip.repository.TripMemberRepository;
import com.tripan.app.mapper.TripMemberMapper;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
@Transactional
public class TripMemberServiceImpl implements TripMemberService {

    private final TripMemberRepository memberRepository; // CUD 담당
    private final TripMemberMapper memberMapper;         // Read 담당

    @Override
    public void updateMemberRole(Long tripId, Long targetMemberId, String newRole, Long requesterId) {
        // 요청자가 방장(OWNER)인지 확인
        TripMember requester = memberMapper.findByTripIdAndMemberId(tripId, requesterId);
        if (requester == null || !"OWNER".equals(requester.getRole())) {
            throw new IllegalStateException("방장만 권한을 변경할 수 있습니다.");
        }

        // 타겟 멤버 조회 후 Dirty Checking으로 권한 업데이트
        TripMember target = memberRepository.findByTripIdAndMemberId(tripId, targetMemberId)
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 동행자입니다."));

        if ("OWNER".equals(target.getRole())) {
            throw new IllegalStateException("방장의 권한은 변경할 수 없습니다.");
        }

        target.setRole(newRole); // JPA가 트랜잭션 종료 시 자동으로 UPDATE 쿼리 실행
    }

    @Override
    public void kickMember(Long tripId, Long targetMemberId, Long requesterId) {
        // 요청자가 방장인지 확인
        TripMember requester = memberMapper.findByTripIdAndMemberId(tripId, requesterId);
        if (requester == null || !"OWNER".equals(requester.getRole())) {
            throw new IllegalStateException("방장만 멤버를 강퇴할 수 있습니다.");
        }

        // 방장은 강퇴 불가 처리 후 삭제
        TripMember target = memberRepository.findByTripIdAndMemberId(tripId, targetMemberId)
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 동행자입니다."));

        if ("OWNER".equals(target.getRole())) {
            throw new IllegalStateException("방장을 강퇴할 수는 없습니다.");
        }

        memberRepository.delete(target);
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