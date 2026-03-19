package com.tripan.app.admin.domain.dto;

import java.math.BigDecimal;
import java.util.Date;
import java.util.List;
import java.util.Map;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PartnerManageDto {

    // ── partner 테이블 ───────────────────────────────────────
    private Long       partnerId;
    private Long       memberId;
    private String     partnerName;
    private String     logoImageUrl;
    private String     businessNumber;
    private String     contactName;
    private String     contactPhone;
    private String     contactEmail;
    private String     hasExp;
    private String     bankName;
    private String     accountNumber;
    private String     contractFileUrl;   // partner.contractfile_url (심사 전 계약서)
    private BigDecimal commissionRate;
    private Integer    status;            // partner.status 숫자 (1=활성, 0=비활성)
    private Date       createdAt;

    // ── partner_status 테이블 (최신 1건 JOIN) ────────────────
    private String statusCode;       // PENDING / ACTIVE / REJECTED / SUSPENDED / BLOCKED
    private String statusMemo;       // 반려사유 등 메모
    private Date   statusUpdatedAt;  // partner_status.reg_date

    // ── partner_contract 테이블 (최신 1건 JOIN) ──────────────
    private Date   contractStartDate;
    private Date   contractEndDate;
    private String contractMemo;

    // ── 요청 파라미터 (DB 컬럼 아님) ────────────────────────
    private Long    applyId;   // apply 화면에서 partnerId 대신 사용
    private String  message;   // 반려사유 / 승인메시지 (심사 처리 요청 시)
    private List<Map<String, Object>> docs; // 제출 서류 목록

    /**
     * DB에서 받지 않고 statusCode 기준으로 계산하는 한국어 상태 라벨.
     * statusCode가 없으면 partner.status 숫자(1/0)로 폴백.
     */
    public String getStatusLabel() {
        String s = (statusCode != null && !statusCode.isEmpty()) ? statusCode
                 : (status != null ? (status == 1 ? "ACTIVE" : "SUSPENDED") : "");
        return switch (s.toUpperCase()) {
            case "PENDING"   -> "승인대기";
            case "ACTIVE"    -> "정상";
            case "REJECTED"  -> "반려";
            case "SUSPENDED" -> "이용정지";
            case "BLOCKED"   -> "영구차단";
            default          -> s;
        };
    }
}