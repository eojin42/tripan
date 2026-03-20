package com.tripan.app.admin.domain.dto;

import lombok.Data;
import java.math.BigDecimal;
import java.util.List;

/**
 * 파트너 정산 DTO
 *
 * ▶ 목록(main) 용도 : placeId == null  → 파트너 단위 집계 row
 * ▶ 상세(detail) 용도: placeId != null → 숙소 단위 집계 row + orders 하위 목록
 *
 * Summary/Detail 두 DTO를 하나로 합쳤습니다.
 * 공통 필드(memberId~netPayout)는 두 용도 모두 사용하고,
 * 숙소 단위 전용 필드(placeId 이하)는 목록에서는 null로 옵니다.
 */
@Data
public class SettlementManageDto {

    /* ── 파트너 공통 ──────────────────────────── */
    private Long   memberId;
    private String loginId;
    private String nickname;
    private String settlementMonth;     // YYYY-MM

    /* ── 목록(파트너 단위) 전용 ──────────────── */
    private int    placeCount;          // 관리 숙소 수
    private int    approvedPlaceCount;  // 승인 완료 숙소 수
    private String region;              // 대표 지역

    /* ── 숙소 단위 전용 ──────────────────────── */
    private Long   placeId;
    private String placeName;
    private String placeType;           // acc_type
    private String placeRegion;
    private BigDecimal commissionRate;
    private Long   settlementId;        // settlement 테이블 PK

    /* ── 공통 집계 금액 ──────────────────────── */
    private BigDecimal totalGmv;            // 총 결제액
    private BigDecimal totalCommission;     // 총 수수료
    private BigDecimal totalCouponPlatform; // 쿠폰 플랫폼 부담 합계
    private BigDecimal totalCouponPartner;  // 쿠폰 파트너 부담 합계 (정산 차감)
    private BigDecimal totalNetPayout;      // 최종 지급액

    /* ── 정산 상태 ───────────────────────────── */
    // 목록: PENDING / PARTIAL / DONE
    // 상세: PENDING / APPROVED
    private String settlementStatus;

    /* ── 예약 건수 (상세 전용) ───────────────── */
    private int orderCount;

    /* ── 예약 건별 목록 (상세 아코디언 전용) ─── */
    private List<SettlementOrderDto> orders;
}
