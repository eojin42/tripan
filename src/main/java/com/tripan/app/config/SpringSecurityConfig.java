package com.tripan.app.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.core.session.SessionRegistry;
import org.springframework.security.core.session.SessionRegistryImpl;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.access.ExceptionTranslationFilter;
import org.springframework.security.web.savedrequest.HttpSessionRequestCache;
import org.springframework.security.web.session.HttpSessionEventPublisher;

import com.tripan.app.security.AjaxSessionTimeoutFilter;
import com.tripan.app.security.LoginFailureHandler;
import com.tripan.app.security.LoginSuccessHandler;

@Configuration
@EnableWebSecurity
public class SpringSecurityConfig {
	@Bean
	SecurityFilterChain filterChain(HttpSecurity http) throws Exception{
		HttpSessionRequestCache requestCache = new HttpSessionRequestCache();
		requestCache.setMatchingRequestParameterName(null);
		
		String[] excludeUri = {
				"/", "/index.jsp", 
				"/member/login", "/member/account", "/member/logout", "/member/nicknameCheck", 
				"/member/userIdCheck", "/member/complete", "/member/pwdFind", "/member/expired", "/partner/login",
				"/dist/**",
				"/guest/main", "/guest/list", 
				"/uploads/photo/**", "/uploads/feed/**", "/uploads/review/**",
				"/favicon.ico", "/WEB-INF/views/**",
				"/oauth/kakao/callback", 
				"/accommodation/home", "/accommodation/list", "/accommodation/search", "/accommodation/detail/*", "/accommodation/review/list/*", 
				"/community/feed", "/community/fragment/feed", 
				"/api/festivals/**", "/api/chat/rooms/region",
				"/ws-tripan/**",
				"/partner/api/check-session",
			    };
		
		http.cors(Customizer.withDefaults())
			.csrf(AbstractHttpConfigurer::disable)
			.requestCache(request -> request.requestCache(requestCache));
		
		http.authorizeHttpRequests(authorize -> authorize
				.requestMatchers(excludeUri).permitAll()
				.requestMatchers("/admin/**").hasRole("ADMIN")
				.requestMatchers("/**").hasAnyRole("USER","ADMIN","PARTNER")
				.anyRequest().authenticated()
				)
		.formLogin(login -> login
				.loginPage("/member/login")
				.loginProcessingUrl("/member/login")
				.usernameParameter("loginId")
				.passwordParameter("password")
				.successHandler(loginSuccessHandler())
				.failureHandler(loginFailureHandler())
				.permitAll()
				)
		.logout(logout -> logout
				.logoutUrl("/member/logout")
				.invalidateHttpSession(true)
				.deleteCookies("JSESSIONID")
				.logoutSuccessUrl("/")
				)
		.addFilterAfter(ajaxSessionTimeoutFilter(), ExceptionTranslationFilter.class)
		.sessionManagement(management -> management
				.maximumSessions(1)
				.sessionRegistry(sessionRegistry())
				.expiredSessionStrategy(event -> {
					jakarta.servlet.http.HttpServletRequest request = event.getRequest();
					jakarta.servlet.http.HttpServletResponse response = event.getResponse();
					String uri = request.getRequestURI();
					String ajaxHeader = request.getHeader("AJAX");

					if ("true".equals(ajaxHeader)) {
						response.sendError(jakarta.servlet.http.HttpServletResponse.SC_UNAUTHORIZED, "Ajax Session Expired");
					} else {
						if (uri.startsWith("/partner")) {
							response.sendRedirect(request.getContextPath() + "/partner/login");
						} else {
							response.sendRedirect(request.getContextPath() + "/member/login");
						}
					}
				})
		)
		.exceptionHandling(exception -> exception
				.authenticationEntryPoint((request, response, authException) -> {
					String uri = request.getRequestURI();
					String ajaxHeader = request.getHeader("AJAX");
					boolean isAjax = ajaxHeader != null && ajaxHeader.equals("true");

					if (isAjax) {
						response.sendError(jakarta.servlet.http.HttpServletResponse.SC_UNAUTHORIZED, "Ajax Session Expired");
					} else {
						if (uri.startsWith("/partner")) {
							response.sendRedirect(request.getContextPath() + "/partner/login");
						} else {
							response.sendRedirect(request.getContextPath() + "/member/login");
						}
					}
				})
		);
		
		return http.build();
	}
	
	@Bean
	PasswordEncoder passwordEncoder() {
		return new BCryptPasswordEncoder();
	}
	
	@Bean
	LoginSuccessHandler loginSuccessHandler() {
		LoginSuccessHandler handler = new LoginSuccessHandler();
		handler.setDefaultUrl("/");
		return handler;
	}
	
	@Bean
	LoginFailureHandler loginFailureHandler() {
		LoginFailureHandler handler = new LoginFailureHandler();
		handler.setDefaultFailureUrl("/member/login?error");
		return handler;
	}

	@Bean
	AjaxSessionTimeoutFilter ajaxSessionTimeoutFilter() {
		AjaxSessionTimeoutFilter filter = new AjaxSessionTimeoutFilter();
		filter.setAjaxHeader("AJAX");
		return filter;
	}
	
	@Bean
	public HttpSessionEventPublisher httpSessionEventPublisher() {
		return new HttpSessionEventPublisher();
	}
	
	@Bean
	public SessionRegistry sessionRegistry() {
		return new SessionRegistryImpl();
	}
	
}
