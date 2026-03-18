package com.tripan.app.admin.domain.dto;

import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;

import java.math.BigDecimal;
import java.util.Date;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PartnerManageDto {

	private Long       partnerId;       // partner_id (PK)
    private Long       memberId;        // member_id
    private String     partnerName;     // partner_name
    private String     logoImageUrl;    // logo_image_url
    private String     businessNumber;  // business_number
    private String     contactName;     // contact_name
    private String     contactPhone;    // contact_phone
    private String     bankName;        // bank_name
    private String     accountNumber;   // account_number
    private String     status;          // PENDING / ACTIVE / REJECTED / SUSPENDED / BLOCKED
    private Date       createdAt;       // created_at
    private BigDecimal commissionRate;  // commission_rate
    private String     contractFileUrl; // contract_file_url
    private String     partnerIntro;    // partner_intro
    private String     rejectReason;    // reject_reason
    private String     updatedAt;       // updated_at
 
    private String statusLabel;  // 상태 한글 라벨 (toDto에서 세팅)
 
    private String managerEmail; // DB 컬럼 없음
    private String memo;         // DB 컬럼 없음
 
    private Long    applyId;     // 심사 대상 partnerId
    private String  result;      // APPROVED / REJECTED
    private String  message;     // 반려 사유 또는 처리 메시지
    private boolean sendNotify;  // 알림 발송 여부
}
