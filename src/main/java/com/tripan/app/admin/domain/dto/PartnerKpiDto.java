package com.tripan.app.admin.domain.dto;

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
public class PartnerKpiDto {

	private int    total;             // 전체 (PENDING 제외 심사완료)
    private int    pending;           // 승인 대기 (PENDING)
    private int    active;            // 활성 (ACTIVE)
    private int    suspended;         // 정지 (SUSPENDED / BLOCKED)
    private int    rejected;          // 반려 (REJECTED)
    private int    approvedThisMonth; // 이번 달 신규 승인
    private String totalSalesLabel;   // 이번 달 총 매출 라벨
    private int    lowRatingCount;    // 저평점 위험 파트너 수
}
