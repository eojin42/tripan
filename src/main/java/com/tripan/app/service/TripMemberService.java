package com.tripan.app.service;

public interface TripMemberService {
    //  멤버 권한 변경 (방장 전용)
    void updateMemberRole(Long tripId, Long targetMemberId, String newRole, Long requesterId);
    
    //  멤버 강퇴 (방장 전용)
    //  targetNickname: 강퇴 대상 닉네임 (RestController에서 세션 또는 DB로 조회해서 전달)
    void kickMember(Long tripId, Long targetMemberId, Long requesterId, String targetNickname);
    
    //  스스로 여행 나가기 (방장 제외)
    //  requesterNickname: 나가는 사람 닉네임 (RestController에서 세션으로 조회해서 전달)
    void leaveTrip(Long tripId, Long requesterId, String requesterNickname);
}