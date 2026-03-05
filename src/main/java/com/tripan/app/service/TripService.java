package com.tripan.app.service;

import com.tripan.app.domain.dto.TripCreateDto;

public interface TripService {

	// 여행 방 기본 CUD 로직 // 
	/**
     * 신규 여행 방을 생성하고 뼈대 데이터(일차, 방장, 태그, 도시)를 구축
     * * @param dto 여행 생성에 필요한 기본 데이터 (제목, 날짜, 예산, 태그, 도시 등)
     * @param memberId 방장(OWNER)으로 등록될 회원의 고유 ID
     * @return 생성된 여행 방의 고유 식별자 (tripId)
     */
	public Long createTrip(TripCreateDto dto, Long memberId);
	
	
	/**
     * 여행 방의 기본 정보를 수정하고, 날짜 변경 시 일차(TripDay) 데이터를 동기화
     * (기존 태그 삭제 후 재등록 로직 포함)
     * * @param tripId 수정할 여행 방 ID
     * @param dto 수정할 데이터 (변경된 제목, 날짜, 예산, 태그 등)
     */
	public void updateTrip(Long tripId, TripCreateDto dto);
	
	
	/**
     * 특정 여행 방과 관련된 모든 하위 데이터(일정, 가계부, 동행자 등)를 일괄 삭제
     * * @param tripId 삭제할 여행 방의 고유 ID
     */
    public void deleteTrip(Long tripId);
    
    
    /**
     * 여행 방의 진행 상태를 변경 (예: PLANNING -> COMPLETED)
     * * @param tripId 여행 방의 고유 ID
     * @param status 변경할 상태 값
     */
    public void updateTripStatus(Long tripId, String status);
    
    
    
    
    // 여행 담아오기 (복제) 로직 // 
    /**
     * 공개된 타인의 여행 방을 내 워크스페이스로 복제(딥 카피)
     * (체크리스트, 투표 등 개인화된 정보는 제외하고 일정 뼈대와 장소, 태그만 복사)
     * * @param originalTripId 복제할 원본 여행 방의 고유 ID
     * @param memberId 복사본의 방장이 될 회원의 고유 ID
     * @return 새로 생성된 복사본 여행 방의 고유 식별자 (newTripId)
     */
    public Long cloneTrip(Long originalTripId, Long memberId);
    
    
    
    
    
    // 여행 동행자 초대 및 참여 로직 //
    /**
     * 초대 링크(코드)를 통해 특정 여행 방에 동행자로 즉시 참여
     * (권한: EDITOR, 상태: ACCEPTED 자동 부여)
     * * @param inviteCode 여행 방에 부여된 랜덤 초대 문자열
     * @param memberId 링크를 클릭하여 참여할 회원의 고유 ID
     * @return 참여가 완료된 여행 방의 고유 식별자 (tripId)
     */
    public Long joinTripViaLink(String inviteCode, Long memberId);
    
    
    /**
     * 방장이 아이디 검색을 통해 특정 회원을 여행 방에 초대
     * (알림 발송 및 초대 상태를 PENDING으로 등록)
     * * @param tripId 초대를 보낼 여행 방의 고유 ID
     * @param inviteeId 초대를 받을 회원의 고유 ID
     */
    public void inviteMemberToTrip(Long tripId, Long inviteeId);
    
    
    /**
     * PENDING 상태인 초대를 회원이 수락하여 ACCEPTED 상태로 변경
     * * @param tripId 참여할 여행 방의 고유 ID
     * @param memberId 초대를 수락할 회원의 고유 ID
     */
    public void acceptTripInvitation(Long tripId, Long memberId);
    
    
    
    
    
	
}
