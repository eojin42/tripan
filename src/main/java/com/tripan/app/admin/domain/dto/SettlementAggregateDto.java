package com.tripan.app.admin.domain.dto;

import java.math.BigDecimal;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class SettlementAggregateDto {
	private Long       partnerId;        // partner.partner_id
    private String     settlementMonth;  // 'YYYY-MM' 형식
 
    private BigDecimal totalSales;       // 총 결제액 합산 (orders.real_total_amount)
    private BigDecimal commissionAmount; // 수수료 합산 (totalSales × commission_rate / 100)
    private BigDecimal netAmount;        // 최종 지급액 (totalSales - commissionAmount)
}
