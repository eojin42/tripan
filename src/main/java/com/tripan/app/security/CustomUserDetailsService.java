package com.tripan.app.security;

import java.util.ArrayList;
import java.util.List;

import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import com.tripan.app.domain.dto.MemberDto;
import com.tripan.app.domain.dto.SessionInfo;
import com.tripan.app.service.MemberService;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class CustomUserDetailsService implements UserDetailsService{
	private final MemberService memberService;
	
	@Override
	public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
		
		MemberDto member = memberService.findById(username);
		
		if(member == null) {
			throw new UsernameNotFoundException("아이디가 존재하지 않습니다.");
		}
		
		List<String> authorities = new ArrayList<>();
		authorities.add(member.getRole()); 
		
		return toUserDetails(member, authorities);
	}
	
	private UserDetails toUserDetails(MemberDto member, List<String>authorities) {
		SessionInfo info = SessionInfo.builder()
				.memberId(member.getMemberId())
				.loginId(member.getLoginId())
				.password(member.getPassword())
				.username(member.getUsername())
				.email(member.getEmail())
				.status(member.getStatus())
				.role(member.getRole())
				.failureCnt(member.getFailureCnt())
				.nickname(member.getNickname())
				.avatar(member.getProfilePhoto())
				.equippedBadgeId(member.getEquippedBadgeId())
				.provider(member.getSnsProvider())
				.providerId(member.getSnsId())
				.build();
		
		return CustomUserDetails.builder()
				.sessionInfo(info)
				.disabled(member.getStatus() == 0)
				.roles(authorities)
				.build();	
	}
}