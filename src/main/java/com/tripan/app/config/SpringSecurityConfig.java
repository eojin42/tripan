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
				"/uploads/banner/**", "/uploads/photo/**", "/uploads/feed/**", "/uploads/review/**",
				"/favicon.ico", "/WEB-INF/views/**",
				"/oauth/kakao/callback", 
				"/accommodation/home", "/accommodation/list", "/accommodation/search", "/accommodation/detail/*", "/accommodation/review/list/*", "/accommodation/review/photos/*",
				"/accommodation/coupon/*", "/accommodation/coupon", "/accommodation/room/detail/api/**",
				"/community/feed", "/community/fragment/feed", 
				"/api/festivals/**", "/api/chat/rooms/region",
				"/ws-tripan/**", "/feed/feed_list", "/feed/public-trips",
				"/partner/api/check-session",
			    };
		
		http.cors(Customizer.withDefaults())
			.csrf(AbstractHttpConfigurer::disable)
			.requestCache(request -> request.requestCache(requestCache));
		
		http.authorizeHttpRequests(authorize -> authorize
				.requestMatchers(excludeUri).permitAll()
				.requestMatchers("/api/admin/**").hasRole("ADMIN") 
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
				.logoutSuccessHandler((request, response, authentication) -> {
					String referer = request.getHeader("Referer");
					if (referer != null && referer.contains("/partner")) {
						response.sendRedirect(request.getContextPath() + "/partner/login");
					} else {
						response.sendRedirect(request.getContextPath() + "/");
					}
				})
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
				.accessDeniedHandler((request, response, accessDeniedException) -> {
			        request.setAttribute("title", "접근 권한이 없습니다.");
			        request.setAttribute("message", "죄송합니다.<br><strong>403 - 관리자만 접근할 수 있는 페이지입니다.</strong>");
			        request.getRequestDispatcher("/error/403").forward(request, response);
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