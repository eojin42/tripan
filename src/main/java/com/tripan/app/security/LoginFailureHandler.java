package com.tripan.app.security;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.DisabledException;
import org.springframework.security.authentication.InternalAuthenticationServiceException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.authentication.AuthenticationFailureHandler;

import com.tripan.app.domain.dto.MemberDto;
import com.tripan.app.service.MemberService;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;

@Slf4j
public class LoginFailureHandler implements AuthenticationFailureHandler{
	@Autowired
	private MemberService memberService;
	
	private String defaultFailureUrl;
	
	@Override
	public void onAuthenticationFailure(HttpServletRequest request, HttpServletResponse response,
			AuthenticationException exception) throws IOException, ServletException {
		String login_id = request.getParameter("login_id");
		
		String msg = "로그인 실패";
		try {
			if(exception instanceof BadCredentialsException) {
				
				int cnt = memberService.checkFailureCount(login_id);
				if(cnt <= 4) {
					memberService.updateFailureCount(login_id);
				}
				
				if(cnt == 4) {
					MemberDto dto = memberService.findById(login_id);
					
					Map<String, Object> map = new HashMap<>();
					map.put("enabled", 0);
					map.put("member_id",dto.getMemberId());
					memberService.updateMemberEnabled(map);
					
					/*
					dto.setReporterId(dto.getMemberId());
					dto.setStatus("INACTIVE");
					dto.setReason("패스워드 5회 이상 실패");
					memberService.insertMemberStatus(dto);*/
				}
				msg = "패스워드 불일치";
			}else if(exception instanceof InternalAuthenticationServiceException) {
				msg = "존재하지 않은 아이디";
			}else if(exception instanceof DisabledException) {
				msg = "계정 비활성화";
			}
		} catch (Exception e) {
			log.info("Login Failure : "+ msg, e);   
			 
		}
		response.sendRedirect(defaultFailureUrl);
	}

	public void setDefaultFailureUrl(String defaultFailureUrl) {
		this.defaultFailureUrl = defaultFailureUrl;
	}

}
