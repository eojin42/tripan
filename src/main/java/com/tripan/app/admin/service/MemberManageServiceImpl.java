package com.tripan.app.admin.service;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.tripan.app.admin.domain.dto.ReservationResponseDto;
import com.tripan.app.admin.domain.dto.DormantKpiDto;
import com.tripan.app.admin.domain.dto.DormantMemberDto;
import com.tripan.app.admin.domain.dto.MemberDto;
import com.tripan.app.admin.domain.dto.MemberKpiDto;
import com.tripan.app.admin.domain.dto.CouponDto;
import com.tripan.app.admin.domain.dto.PointManageDto;
import com.tripan.app.admin.domain.entity.Member1;
import com.tripan.app.admin.domain.entity.Member3;
import com.tripan.app.admin.mapper.ReservationManageMapper;
import com.tripan.app.admin.mapper.MemberManageMapper;
import com.tripan.app.admin.repository.Member1ManageRepository;
import com.tripan.app.admin.repository.Member2ManageRepository;
import com.tripan.app.admin.repository.Member3ManageRepository;
import com.tripan.app.admin.repository.MemberStatusManageRepository;
import com.tripan.app.domain.entity.MemberStatus;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class MemberManageServiceImpl implements MemberManageService {

    private final MemberManageMapper           memberMapper;
    private final Member1ManageRepository      member1Repository;
    private final Member2ManageRepository      member2Repository;
    private final MemberStatusManageRepository memberStatusRepository;
    private final Member3ManageRepository      member3Repository;
    private final ReservationManageMapper      bookingMapper;

    @Override
    public List<MemberDto> getAllMembers() {
        return memberMapper.selectAllMembers();
    }

    @Override
    public MemberDto getMemberDetail(Long memberId) {
        MemberDto member = memberMapper.selectMemberDetail(memberId);
        List<ReservationResponseDto> bookings = bookingMapper.selectBookingsByMemberId(memberId);
        member.setBookingList(bookings);
        return member;
    }

    // ─────────────────────────────────────────
    //  상태 + 역할 변경
    // ─────────────────────────────────────────
    @Override
    public List<PointManageDto.HistoryDto> getPointHistory(Long memberId) {
        return memberMapper.selectPointHistory(memberId);
    }

    @Override
    public List<CouponDto.IssuedItem> getMemberCoupons(Long memberId) {
        return memberMapper.selectMemberCoupons(memberId);
    }

    @Transactional
    @Override
    public void updateMemberStatus(Long targetId, Integer newStatus, String role, String memo, Long adminId) {
        Member1 targetMember = member1Repository.findById(targetId)
                .orElseThrow(() -> new IllegalArgumentException("대상 회원을 찾을 수 없습니다."));
        Member1 adminMember = member1Repository.findById(adminId)
                .orElseThrow(() -> new IllegalArgumentException("관리자 정보를 찾을 수 없습니다."));

        // 상태 변경
        targetMember.setStatus(newStatus == 1 ? 1 : 0);

        // 역할 변경 (null 이나 빈 값이면 기존 유지)
        if (role != null && !role.isBlank()) {
            targetMember.setRole(role);
        }

        // 상태 이력 저장
        saveMemberStatusLog(targetMember, adminMember, newStatus, memo);

        // 탈퇴(4) 추가 처리
        if (newStatus == 4) {
            Member3 withdrawInfo = new Member3();
            withdrawInfo.setMember1(targetMember);
            withdrawInfo.setWithdrawDate(LocalDateTime.now());
            withdrawInfo.setWithdrawReason(memo);
            member3Repository.save(withdrawInfo);
        }

        log.info("[관리자] 상태/역할 변경 targetId={} status={} role={} adminId={}",
                targetId, newStatus, role, adminId);
    }

    @Override
    public MemberKpiDto getMemberKpi() {
        MemberKpiDto kpi = memberMapper.selectMemberKpi();
        int today     = kpi.getTodayNewCount();
        int yesterday = kpi.getYesterdayNewCount();
        if (yesterday == 0) {
            kpi.setDailyTrend(today > 0 ? 100.0 : 0.0);
        } else {
            double trend = ((double)(today - yesterday) / yesterday * 100);
            kpi.setDailyTrend(Math.round(trend * 10) / 10.0);
        }
        return kpi;
    }

    @Override
    public List<DormantMemberDto> getDormantMembers() {
        return memberMapper.selectDormantMembers();
    }

    @Override
    public DormantKpiDto getDormantKpi() {
        return memberMapper.selectDormantKpi();
    }

    @Transactional
    @Override
    public void bulkUpdateStatus(List<Long> targetIds, Integer newStatus, String memo, Long adminId) {
        if (targetIds == null || targetIds.isEmpty()) return;
        Member1 adminMember = member1Repository.findById(adminId)
                .orElseThrow(() -> new IllegalArgumentException("관리자 정보를 찾을 수 없습니다."));
        for (Long targetId : targetIds) {
            Member1 targetMember = member1Repository.findById(targetId)
                    .orElseThrow(() -> new IllegalArgumentException("대상 회원을 찾을 수 없습니다. id=" + targetId));
            targetMember.setStatus(newStatus == 1 ? 1 : 0);
            saveMemberStatusLog(targetMember, adminMember, newStatus, memo);
            if (newStatus == 4) {
                Member3 withdrawInfo = new Member3();
                withdrawInfo.setMember1(targetMember);
                withdrawInfo.setWithdrawDate(LocalDateTime.now());
                withdrawInfo.setWithdrawReason(memo);
                member3Repository.save(withdrawInfo);
                maskMember1(targetMember);
                maskMember2(targetMember);
            }
        }
        log.info("[관리자] 일괄 상태 변경 {}명 status={} adminId={}", targetIds.size(), newStatus, adminId);
    }

    @Transactional
    @Override
    public void restoreDormantMember(Long targetId, Long adminId) {
        Member1 targetMember = member1Repository.findById(targetId)
                .orElseThrow(() -> new IllegalArgumentException("대상 회원을 찾을 수 없습니다."));
        Member1 adminMember = member1Repository.findById(adminId)
                .orElseThrow(() -> new IllegalArgumentException("관리자 정보를 찾을 수 없습니다."));
        targetMember.setStatus(1);
        saveMemberStatusLog(targetMember, adminMember, 1, "관리자 휴면복귀처리");
        log.info("[관리자] 휴면 복귀 targetId={} admin={}", targetId, adminId);
    }

    @Transactional
    @Override
    public void sendReactivationMail(String email) {}

    @Transactional
    @Override
    public void bulkSendReactivationMail(List<String> emails) {}

    private void saveMemberStatusLog(Member1 target, Member1 admin, Integer status, String memo) {
        MemberStatus statusLog = new MemberStatus();
        statusLog.setTargetMember(target);
        statusLog.setStatus(status);
        statusLog.setMemo(memo);
        statusLog.setRegDate(LocalDateTime.now());
        statusLog.setRegisterMember(admin);
        memberStatusRepository.save(statusLog);
    }

    private void maskMember1(Member1 member) {
        member.setLoginId("deleted_" + member.getId());
        member.setEmail("deleted_" + member.getId() + "@removed.com");
        member.setUsername("(탈퇴)");
        member.setPassword("deleted_password_!" + java.util.UUID.randomUUID().toString());
        member.setGender(null);
        member.setBirthday(null);
        member.setProvider(null);
        member.setProviderId(null);
        member.setFailureCnt(null);
        member.setStatus(0);
    }

    private void maskMember2(Member1 target) {
        member2Repository.findByMember1(target).ifPresent(m2 -> {
            m2.setNickname("(탈퇴)");
            m2.setProfileImage(null);
            m2.setBio(null);
            m2.setPhoneNumber(null);
            m2.setPreferredRegion(null);
        });
    }
}