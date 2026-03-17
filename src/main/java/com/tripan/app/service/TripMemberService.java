package com.tripan.app.service;

public interface TripMemberService {
    //  멤버 권한 변경 (방장 전용)
    void updateMemberRole(Long tripId, Long targetMemberId, String newRole, Long requesterId);
    
    //  멤버 강퇴 (방장 전용)
    void kickMember(Long tripId, Long targetMemberId, Long requesterId);
    
    //  스스로 여행 나가기 (방장 제외)
    void leaveTrip(Long tripId, Long requesterId);
}