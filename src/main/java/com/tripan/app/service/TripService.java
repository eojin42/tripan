package com.tripan.app.service;

import java.util.List;
import com.tripan.app.domain.dto.TripCreateDto;
import com.tripan.app.domain.dto.TripDto;

public interface TripService {

    // 신규 여행 방 생성 및 초기 데이터(방장, 일차, 태그, 지역) 구축
    Long createTrip(TripCreateDto dto, Long memberId);

    // 여행 정보 수정 및 날짜 변경에 따른 일차 데이터 동기화(추가/삭제)
    void updateTrip(Long tripId, TripCreateDto dto);

    // 여행 방 및 모든 하위 연관 데이터 일괄 삭제
    void deleteTrip(Long tripId);

    // 여행 진행 상태 변경 (예: PLANNING -> COMPLETED)
    void updateTripStatus(Long tripId, String status);

    // 워크스페이스 진입 시 필요한 여행 상세 정보(일정, 멤버 등) 일괄 조회
    TripDto getTripDetails(Long tripId);

    // 태그 자동완성용 키워드 검색
    List<String> searchTags(String keyword);

    // 공개 설정된 타인의 여행 방 검색
    List<TripDto> searchPublicTrips(String keyword);

    // 타인의 여행 일정을 내 워크스페이스로 복제 (딥 카피)
    Long cloneTrip(Long originalTripId, Long memberId);

    // 초대 링크를 통해 여행 방에 즉시 참여 (EDITOR 권한)
    Long joinTripViaLink(String inviteCode, Long memberId);

    // 아이디 검색으로 특정 유저 초대 (PENDING 상태로 등록)
    void inviteMemberToTrip(Long tripId, Long inviteeId);

    // 받은 초대를 수락하여 정식 동행자로 상태 변경
    void acceptTripInvitation(Long tripId, Long memberId);

    // 참여 중인 여행 방에서 스스로 나가기
    void leaveTrip(Long tripId, Long memberId);

    // 특정 동행자 강제 퇴장 처리 (방장 전용)
    void kickMember(Long tripId, Long targetMemberId);
}