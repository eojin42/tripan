package com.tripan.app.service;

import java.util.List;
import java.util.Map;

import com.tripan.app.domain.dto.MemberDto;

public interface MemberService {
	public MemberDto loginSnsMember(Map<String, Object> map);
	
	public void insertMember(MemberDto dto, String uploadPath) throws Exception;
	public void insertSnsMember(MemberDto dto) throws Exception;
	public void insertMemberStatus(MemberDto dto) throws Exception;
	
	public void updatePassword(MemberDto dto) throws Exception;
	public void updateMemberEnabled(Map<String, Object> map) throws Exception;
	public void updateMember(MemberDto dto, String uploadPath) throws Exception;
	
	public void updateLastLogin(Long member_id) throws Exception;
	public void updateLastLogin(String login_id) throws Exception;
	
	public MemberDto findById(Long member_id);
	public MemberDto findById(String login_id);
	public Long getMemberId(String login_id);
	
	public int checkFailureCount(String login_id);
	public void updateFailureCountReset(String login_id) throws Exception;
	public void updateFailureCount(String login_id) throws Exception;
	
	public void deleteMember(Map<String, Object> map, String uploadPath) throws Exception;
	public void deleteProfilePhoto(Map<String, Object> map, String uploadPath) throws Exception;
	
	public void generatePwd(MemberDto dto) throws Exception;
	
	public List<MemberDto> listFindMember(Map<String, Object> map);	
	
	public String findByAuthority(String login_id);
	
	public void insertRefreshToken(MemberDto dto) throws Exception;
	public void updateRefreshToken(MemberDto dto) throws Exception;
	public MemberDto findByToken(String login_id);
	
	public boolean isPasswordCheck(String login_id, String password);		
}
