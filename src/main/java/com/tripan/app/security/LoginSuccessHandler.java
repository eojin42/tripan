package com.tripan.app.security;

import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.web.DefaultRedirectStrategy;
import org.springframework.security.web.RedirectStrategy;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.security.web.savedrequest.HttpSessionRequestCache;
import org.springframework.security.web.savedrequest.RequestCache;
import org.springframework.security.web.savedrequest.SavedRequest;

import com.tripan.app.domain.dto.MemberDto;
import com.tripan.app.service.MemberService;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class LoginSuccessHandler implements AuthenticationSuccessHandler {
    private RequestCache requestCache = new HttpSessionRequestCache();
    private RedirectStrategy redirectStrategy = new DefaultRedirectStrategy();
    private String defaultUrl;
    
    @Autowired
    private MemberService memberService;
    
    private static final String[] IGNORE_REDIRECT_PATHS = {
            "/fragment/", 
            "/api/", 
            "/uploads/",
            "/ws-tripan/" 
        };
    
    private static final String[] IGNORE_REDIRECT_EXTENSIONS = {
            ".jpg", ".jpeg", ".png", ".gif", ".svg", ".ico",
            ".css", ".js", ".woff", ".woff2", ".ttf", ".webp"
        };
    
    @Override
    public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response,
            Authentication authentication) throws IOException, ServletException {
    	System.out.print(authentication.getName());
    	
    	try {
			// 로그인 날짜 변경
			memberService.updateLastLogin(authentication.getName());

			// 패스워드 변경이 90일이 지난 경우 패스워드 변경 폼으로 이동
			// 로그인 정보 저장
			MemberDto dto = memberService.findById(authentication.getName());
			request.getSession().setAttribute("loginUser", dto);
			
			DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
			LocalDateTime currentDateTime = LocalDateTime.now();
			LocalDateTime targetDateTime = LocalDateTime.parse(dto.getUpdateAt(), formatter);
			long daysBetween = ChronoUnit.DAYS.between(targetDateTime, currentDateTime);
			if (daysBetween >= 90) {
				String targetUrl = "/member/updatePwd";
				redirectStrategy.sendRedirect(request, response, targetUrl);
				return;
			}
		} catch (Exception e) {
		}
    	
        resultRedirectStrategy(request, response, authentication);
    }
    
    protected void resultRedirectStrategy(HttpServletRequest request, 
            HttpServletResponse response,
            Authentication authentication) throws IOException, ServletException {
    	
    	String refererHeader = request.getHeader("Referer");
    	if (refererHeader != null && refererHeader.contains("/partner/login")) {
            redirectStrategy.sendRedirect(request, response, "/partner/apply?source=admin");
            return; 
        }

        SavedRequest savedRequest = requestCache.getRequest(request, response);

        if (savedRequest != null) {
            String targetUrl = savedRequest.getRedirectUrl();
            
            boolean isStaticFile = false;
            String lowerUrl = targetUrl.toLowerCase();
            for (String ext : IGNORE_REDIRECT_EXTENSIONS) {
                if (lowerUrl.contains(ext)) {
                    isStaticFile = true;
                    break;
                }
            }
            
            boolean isIgnorePath = false;
            for (String path : IGNORE_REDIRECT_PATHS) {
                if (targetUrl.contains(path)) {
                    isIgnorePath = true;
                    break; 
                }
            }
            
            if (isIgnorePath || isStaticFile) {
                String referer = request.getHeader("Referer");
                if (referer != null && !referer.contains("/member/login")) {
                    redirectStrategy.sendRedirect(request, response, referer);            		
                } else {
                    redirectStrategy.sendRedirect(request, response, defaultUrl);
                }
            } else {
                redirectStrategy.sendRedirect(request, response, targetUrl);
            }
            
        } else {
            String prevPage = (String) request.getSession().getAttribute("prevPage");
            
            if (prevPage != null) {
                request.getSession().removeAttribute("prevPage"); 
                redirectStrategy.sendRedirect(request, response, prevPage);
            } else {
                String referer = request.getHeader("Referer");
                
                if (referer != null && !referer.contains("/member/login")) {
                    redirectStrategy.sendRedirect(request, response, referer);            		
                } else {
                    redirectStrategy.sendRedirect(request, response, defaultUrl);
                }
            }
        }
    }
    
    public void setDefaultUrl(String defaultUrl) {
        this.defaultUrl = defaultUrl;
    }
}