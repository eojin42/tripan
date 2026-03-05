package com.tripan.app.admin.domain.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class MemberKpiDto {
	private int totalCount;      // 전체 회원수
    private int userCount;       // 일반 회원수 (ROLE_USER)
    private int partnerCount;    // 파트너수 (ROLE_PARTNER)
    private int adminCount;      // 관리자수 (ROLE_ADMIN)
    
    private int activeCount;     // 정상 활동 유저 (status = 1)
    private int banCount;        // 활동 정지 유저 (status = 2)
    private int dormantCount;    // 휴면 회원수 (status = 3)
    private int withdrawCount;   // 탈퇴 유저 (status = 4)
    
    
    private int todayNewCount;      // 오늘 신규 가입
    private int yesterdayNewCount;  // 어제 신규 가입
    private double dailyTrend;      // 계산된 증감률 (%)
}
