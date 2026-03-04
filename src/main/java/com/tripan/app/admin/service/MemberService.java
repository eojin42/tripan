package com.tripan.app.admin.service;

import com.tripan.app.admin.domain.entity.Member1;
import java.util.List;

public interface MemberService {

    List<Member1> getAllMembers();

    
    Member1 getMemberDetail(Long memberId);

    
    void changeMemberStatus(Long targetId, Integer newStatus, String memo, Long adminId);

}
