package com.tripan.app.admin.service;

import java.util.List;

import org.springframework.transaction.annotation.Transactional;

import com.tripan.app.admin.domain.entity.Member1;

public class MemberServiceImpl implements MemberService{

	@Override
	public List<Member1> getAllMembers() {
		return null;
	}

	@Override
	public Member1 getMemberDetail(Long memberId) {
		return null;
	}

	@Transactional
	@Override
	public void changeMemberStatus(Long targetId, Integer newStatus, String memo, Long adminId) {
		
	}

}
