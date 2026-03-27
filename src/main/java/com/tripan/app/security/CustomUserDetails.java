package com.tripan.app.security;

import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.oauth2.core.user.OAuth2User;

import com.tripan.app.domain.dto.SessionInfo;

public class CustomUserDetails implements UserDetails, OAuth2User{
	private static final long serialVersionUID = 1L;
	
	private final SessionInfo member;
	private final List<String> roles;
	private final boolean disabled;
	private final Map<String, Object> attributes;
	
	private CustomUserDetails(Builder builder) {
		this.member = builder.member;
		this.roles = builder.roles;
		this.disabled = builder.disabled;
		this.attributes = builder.attributes;
	}
	
	public static class Builder {
		private SessionInfo member;
		private List<String> roles;
		private boolean disabled;
		private Map<String, Object> attributes;
		
		public Builder sessionInfo(SessionInfo member) {
			this.member = member;
			return this;
		}
		
		public Builder roles(List<String> roles) {
			this.roles = roles;
			return this;
		}
		
		public Builder disabled(boolean disabled) {
			this.disabled = disabled;
			return this;
		}
		
		public Builder attributes(Map<String, Object> attributes) {
			this.attributes = attributes;
			return this;
		}
		
		public CustomUserDetails build() {
			if(this.member == null) {
				throw new IllegalStateException("SessionInfo 객체는 필수입니다.");
			}
			
			return new CustomUserDetails(this);
		}
	}
	
	public static Builder builder() {
		return new Builder();
	}
	
	@Override
	public Collection<? extends GrantedAuthority> getAuthorities() {
		
		return roles.stream()
					.map(role->new SimpleGrantedAuthority(role.startsWith("ROLE_")? role : "ROLE_"+role))
					.collect(Collectors.toList());
	}

	@Override
	public String getPassword() {
		return member.getPassword();
	}

	@Override
	public String getUsername() {
		return member.getLoginId();
	}
	
	@Override
	public boolean isEnabled() {
		return ! disabled;
	}
	
	@Override
	public boolean isAccountNonExpired() {
		return true;
	}
	
	@Override
	public boolean isAccountNonLocked() {
		return true;
	}
	
	@Override
	public boolean isCredentialsNonExpired() {
		return true;
	}
	
	public SessionInfo getMember() {
		return member;
	}
	
	@Override
	public boolean equals(Object o) {
		if (this == o) return true;
		if (o == null || getClass() != o.getClass()) return false;
		CustomUserDetails that = (CustomUserDetails) o;
		if (this.member == null || that.member == null) return false;
		return this.member.getLoginId().equals(that.member.getLoginId());
	}

	@Override
	public int hashCode() {
		return member != null && member.getLoginId() != null ? member.getLoginId().hashCode() : 0;
	}

	@Override
	public Map<String, Object> getAttributes() {
		return attributes;
	}

	@Override
	public String getName() {
		return String.valueOf(member.getMemberId());
	}
	
}
