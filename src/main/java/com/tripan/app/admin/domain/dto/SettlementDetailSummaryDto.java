package com.tripan.app.admin.domain.dto;

import java.math.BigDecimal;

import lombok.Data;

@Data
public class SettlementDetailSummaryDto {
	private Long       memberId;
    private String     partnerNickname;
    private String     partnerLoginId;
    private String     settlementMonth;
 
    private BigDecimal totalGmv;
    private BigDecimal totalCommission;
    private BigDecimal totalCouponPlatform;
    private BigDecimal totalCouponPartner;
    private BigDecimal totalNetPayout;
 
    private int  totalPlaceCount;    // 전체 숙소(파트너) 수
    private int  approvedPlaceCount; // 승인 완료 숙소 수
    private boolean allApproved;     // 전체 승인 완료 여부
 
    /* 정산 상태 문자열 — JSP에서 분기 없이 바로 사용 가능 */
    public String getSettlementStatus() {
        if (allApproved)              return "done";
        if (approvedPlaceCount > 0)   return "partial";
        return "wait";
    }
}
