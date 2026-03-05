package com.tripan.app.trip.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.transaction.annotation.Transactional;

import com.tripan.app.trip.domian.entity.TripMember;

// 여행 방의 새로운 멤버 추가/수정/삭제 등
public interface TripMemberRepository extends JpaRepository<TripMember, Long> {

    // 중복 입장 막기 
    boolean existsByTripIdAndMemberId(Long tripId, Long memberId);

    // 방장이 특정 멤버 권한을 VIEWER 편집자(EDITOR)로 변경가능하게 해주기  // 이부분은 뷰어는 내 여행이 공개일 시 내 여행 담아오기 할 수 있게 사람들에게 보여주는 역할 // 편집자는 초대링크나 아이디나 다 들어가면 자동으로 편집 가능하게 
    @Modifying
    @Transactional
    @Query("UPDATE TripMember tm SET tm.role = :role WHERE tm.tripId = :tripId AND tm.memberId = :memberId")
    void updateMemberRole(@Param("tripId") Long tripId, @Param("memberId") Long memberId, @Param("role") String role);

/*
- 동행자 초대 및 참여 로직 (나중에 삭제할거)

링크 복사/아이디 검색으로 초대 가능 

A. 링크 공유로 초대하는 경우 (카톡으로 URL 던지기)
방장이 https://tripan.kr/invite/abc123xyz 링크를 복사해서 친구에게 카톡으로 보냄.
친구가 링크를 클릭해서 들어오면, 서버는 URL에 있는 abc123xyz를 가로채서 TripRepository.findByInviteCode("abc123xyz")로 어떤 방인지 찾기
로그인된 친구라면 서버가 즉시 trip_member 테이블에 이 친구를 INSERT
이때 권한(role)은 같이 일정을 짜야 하니 EDITOR로, 상태(invitation_status)는 본인이 발로 걸어 들어온 거니까 즉시 ACCEPTED로 처리

B. 아이디 검색으로 초대하는 경우 (직접 꽂아 넣기)
방장이 앱 안에서 친구 아이디를 검색해서 "초대하기" 버튼을 누름.
trip_member 테이블에 INSERT 할 때, 권한(role)은 EDITOR로 주되, 초대 상태(invitation_status)를 PENDING(대기중)으로 넣기
친구한테 "**님이 제주도 여행에 초대했습니다"라는 알림(notification 테이블 이용)이 감
친구가 알림에서 "수락"을 누르면, 그때서야 trip_member 테이블의 상태를 'ACCEPTED'로 UPDATE     
 */
   
}
