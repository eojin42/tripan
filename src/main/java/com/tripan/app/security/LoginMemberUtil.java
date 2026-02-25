package com.tripan.app.security;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.logout.SecurityContextLogoutHandler;

import com.tripan.app.common.RequestUtils;
import com.tripan.app.domain.dto.SessionInfo;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class LoginMemberUtil {
	public static SessionInfo getsessionInfo() {
		Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
		
		if(authentication == null || !authentication.isAuthenticated()) {
			return null;
		}
		
		Object principal = authentication.getPrincipal();
		
		if(principal instanceof CustomUserDetails) {
			return ((CustomUserDetails)principal).getMember();
		}
		
		return null;
	}
	
	public static void logout() {
		try {
			HttpServletRequest request = RequestUtils.getCurrentRequest();
			HttpServletResponse response = RequestUtils.getCurrentResponse();
			Authentication auth = SecurityContextHolder.getContext().getAuthentication();
			
			if(auth != null) {
				new SecurityContextLogoutHandler().logout(request, response, auth);
			}
					
		} catch (Exception e) {
		}
	}
}
