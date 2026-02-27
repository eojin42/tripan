package com.tripan.app.domain.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SessionInfo {
	private Long memberId;
	private String loginId;
	private String password;
	private String username;
	private String email;
	private int status;
	private String role;
	private int failureCnt;
	
	private String nickname;
	private String avatar; 
	private Long equippedBadgeId;
	
	private String provider; 
	private String providerId;
}
