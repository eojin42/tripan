package com.tripan.app.admin.service;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.tripan.app.admin.domain.dto.BookingResponseDto;
import com.tripan.app.admin.domain.dto.DormantKpiDto;
import com.tripan.app.admin.domain.dto.DormantMemberDto;
import com.tripan.app.admin.domain.dto.MemberDto;
import com.tripan.app.admin.domain.dto.MemberKpiDto;
import com.tripan.app.admin.domain.entity.Member1;
import com.tripan.app.admin.domain.entity.Member3;
import com.tripan.app.admin.domain.entity.MemberStatus;
import com.tripan.app.admin.mapper.BookingManageMapper;
import com.tripan.app.admin.mapper.MemberManageMapper;
import com.tripan.app.admin.repository.Member1ManageRepository;
import com.tripan.app.admin.repository.Member3ManageRepository;
import com.tripan.app.admin.repository.MemberStatusManageRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class MemberManageServiceImpl implements MemberManageService{
	private final MemberManageMapper memberMapper;
	private final Member1ManageRepository member1Repository;
    private final MemberStatusManageRepository memberStatusRepository;
    private final Member3ManageRepository member3Repository;
    private final BookingManageMapper bookingMapper;
    
	@Override
	public List<MemberDto> getAllMembers() {
		return memberMapper.selectAllMembers();
	}

	@Override
	public MemberDto getMemberDetail(Long memberId) {
		MemberDto member = memberMapper.selectMemberDetail(memberId);
		
		List<BookingResponseDto> bookings = bookingMapper.selectBookingsByMemberId(memberId);
		member.setBookingList(bookings);
		//member.setCsList(csMapper.selectCsHistoryByMemberId(memberId));
		//member.setBadgeList(memberMapper.selectUserBadges(memberId));
		return member;
	}

	@Transactional
	@Override
	public void changeMemberStatus(Long targetId, Integer newStatus, String memo, Long adminId) {
		Member1 targetMember = member1Repository.findById(targetId)
				.orElseThrow(()-> new IllegalArgumentException("대상 회원을 찾을 수 없습니다."));
		
		Member1 adminMember = member1Repository.findById(adminId)
				.orElseThrow(()-> new IllegalArgumentException("관리자 정보를 찾을 수 없습니다."));
		
		targetMember.setStatus(newStatus);
		
		MemberStatus statusLog = new MemberStatus();
		statusLog.setTargetMember(targetMember);
        statusLog.setStatus(newStatus);
        statusLog.setMemo(memo);
        statusLog.setRegDate(LocalDateTime.now());
        statusLog.setRegisterMember(adminMember);
        
        memberStatusRepository.save(statusLog);
        
        if(newStatus == 4) {
        	Member3 withdrawInfo = new Member3();
        	withdrawInfo.setMember1(targetMember);
            withdrawInfo.setRegisterDate(LocalDateTime.now());
            withdrawInfo.setWithdrawDate(LocalDateTime.now());
            withdrawInfo.setWithdrawReason(memo);
            
            member3Repository.save(withdrawInfo);
        }
	}
	
	@Override
	public MemberKpiDto getMemberKpi() {
		MemberKpiDto kpi = memberMapper.selectMemberKpi();
		
		int today = kpi.getTodayNewCount();
		int yesterday = kpi.getYesterdayNewCount();
		
		if(yesterday == 0) {
			kpi.setDailyTrend(today>0? 100.0 : 0.0);
		}else {
			double trend = ((double)(today - yesterday)/yesterday * 100);
			kpi.setDailyTrend(Math.round(trend*10)/10.0);
		}
		
	    return kpi;
	}

	@Override
	public DormantMemberDto getDormantMembers() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public DormantKpiDto getDormantKpi() {
		// TODO Auto-generated method stub
		return null;
	}

}
