package com.tripan.app.admin.domain.dto;

import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;

import java.math.BigDecimal;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PartnerSettlementDto {

	private Long       partnerSettlementId; // partner_settlement_id (PK)
    private Long       partnerId;           // partner_id (FK)
    private String     settlementMonth;     // settlement_month
    private BigDecimal totalSales;          // total_sales
    private BigDecimal commissionAmount;    // commission_amount
    private BigDecimal netAmount;           // net_amount
    private String     status;              // 정산 / 완료 / 대기
 
    private String     partnerName;         // partner.partner_name

}
