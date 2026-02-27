package com.tripan.app.domain.dto;

import org.springframework.web.multipart.MultipartFile;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class MemberDto {
	private Long memberId;
	private String loginId;
	private String nickname;
	private String username;
	private String password;
	private String snsProvider;
	private String snsId;
	private String phoneNumber;
	private String email;
	private String preferredRegion;
	private String bio;
	
	private String ipInfo;
	private String logDate;
	private Long logId;
	
	private String name;
	private String birthday;
	private String gender;
	
	private int status;
	private String role;
	private Long equippedBadgeId;
	
	private String createdAt;
	private String updateAt;
	private String lastLoginAt;
	private int failureCnt;

	private int receiveEmail;
	private String profilePhoto;
	
	private MultipartFile selectFile;
	
	private String reason;
	private Long reporterId;
	
}
