package com.tripan.app.admin.service;

import com.tripan.app.admin.domain.dto.MemberDto;
import com.tripan.app.admin.domain.entity.Member1;
import java.util.List;

public interface MemberManageService {
    List<MemberDto> getAllMembers();
    MemberDto getMemberDetail(Long memberId);
    void changeMemberStatus(Long targetId, Integer newStatus, String memo, Long adminId);
}