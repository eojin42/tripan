package com.tripan.app.admin.service;

import java.util.List;

import com.tripan.app.admin.domain.dto.DormantKpiDto;
import com.tripan.app.admin.domain.dto.DormantMemberDto;
import com.tripan.app.admin.domain.dto.MemberDto;
import com.tripan.app.admin.domain.dto.MemberKpiDto;

public interface MemberManageService {
    List<MemberDto> getAllMembers();
    MemberDto getMemberDetail(Long memberId);
    MemberKpiDto getMemberKpi();
    DormantMemberDto getDormantMembers();
    DormantKpiDto getDormantKpi();
    void changeMemberStatus(Long targetId, Integer newStatus, String memo, Long adminId);
}