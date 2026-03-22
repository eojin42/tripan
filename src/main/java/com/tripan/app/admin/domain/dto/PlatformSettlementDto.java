package com.tripan.app.admin.domain.dto;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.List;

public class PlatformSettlementDto {

    /** KPI 카드 + 워터폴 + 배너 */
    @Getter @Setter @NoArgsConstructor
    public static class KpiDto {
        private long   gmv;
        private long   partnerPayout;
        private long   commission;
        private long   couponDiscount;
        private long   pointUsed;
        private long   netProfit;
        private double commissionRate;
        private long   prevGmv;
        private double gmvTrendPct;
        private int    pendingPartnerCount;
        private long   pendingAmount;
    }

    /** 월별 정산 테이블 한 행 */
    @Getter @Setter @NoArgsConstructor
    public static class MonthlyRowDto {
        private String settlementMonth;
        private long   gmv;
        private long   partnerPayout;
        private long   commission;
        private long   couponDiscount;
        private long   pointUsed;
        private long   netProfit;
        private int    partnerCount;
        private String status;
        private String statusBadgeClass;
        private String statusLabel;
    }

    /** 일별 차트 데이터 한 포인트 */
    @Getter @Setter @NoArgsConstructor
    public static class DailyChartDto {
        /** MM/DD 형식 (예: 03/01) */
        private String day;
        /** 수수료 수익 (원) */
        private long   commission;
        /** 플랫폼 순이익 (원) */
        private long   netProfit;
    }

    /** 페이지 최종 응답 */
    @Getter @Setter @NoArgsConstructor
    public static class PageResponse {
        private KpiDto               kpi;
        private List<MonthlyRowDto>  monthlyList;
        private MonthlyRowDto        total;
        /** 일별 차트 데이터 (month 지정 시 해당 월, 미지정 시 현재 월) */
        private List<DailyChartDto>  dailyChart;
    }

    /** 필터 조건 */
    @Getter @Setter @NoArgsConstructor
    public static class FilterDto {
        private int    year;
        private String month;
    }
}