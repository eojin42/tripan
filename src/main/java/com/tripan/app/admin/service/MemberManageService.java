package com.tripan.app.admin.service;

import java.util.List;

import com.tripan.app.admin.domain.dto.CouponDto;
import com.tripan.app.admin.domain.dto.DormantKpiDto;
import com.tripan.app.admin.domain.dto.DormantMemberDto;
import com.tripan.app.admin.domain.dto.MemberDto;
import com.tripan.app.admin.domain.dto.MemberKpiDto;
import com.tripan.app.admin.domain.dto.PointManageDto;

public interface MemberManageService {

    List<MemberDto> getAllMembers();

    MemberDto getMemberDetail(Long memberId);

    MemberKpiDto getMemberKpi();

    List<DormantMemberDto> getDormantMembers();

    DormantKpiDto getDormantKpi();

    void updateMemberStatus(Long targetId, Integer newStatus, String role, String memo, Long adminId);

    void bulkUpdateStatus(List<Long> targetIds, Integer newStatus, String memo, Long adminId);

    void restoreDormantMember(Long targetId, Long adminId);

    void sendReactivationMail(String email);

    void bulkSendReactivationMail(List<String> emails);
    
    List<PointManageDto.HistoryDto> getPointHistory(Long memberId);
    
    // 보유 쿠폰 내역
    List<CouponDto.IssuedItem> getMemberCoupons(Long memberId);
}