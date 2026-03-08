package com.tripan.app.admin.service;

import java.util.List;

import com.tripan.app.admin.domain.dto.DormantKpiDto;
import com.tripan.app.admin.domain.dto.DormantMemberDto;
import com.tripan.app.admin.domain.dto.MemberDto;
import com.tripan.app.admin.domain.dto.MemberKpiDto;

public interface MemberManageService {

    // SELECT 전용
    MemberKpiDto           getMemberKpi();
    List<MemberDto>        getAllMembers();
    MemberDto              getMemberDetail(Long memberId);
    DormantKpiDto          getDormantKpi();
    List<DormantMemberDto> getDormantMembers();

    // 상태 변경
    void updateMemberStatus(Long targetId, Integer newStatus, String memo, Long adminId);
    void bulkUpdateStatus(List<Long> targetIds, Integer newStatus, String memo, Long adminId);

    // 뱃지
   // void grantBadge(Long memberId, String badgeCode, String grantDate, String adminMemo);
    //void removeBadge(Long memberId, Long badgeId);

    // 휴면 처리
    void restoreDormantMember(Long targetId, Long adminId);

    // 복귀 안내 메일
    void sendReactivationMail(String email);
    void bulkSendReactivationMail(List<String> emails);
}