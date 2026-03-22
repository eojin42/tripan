package com.tripan.app.admin.service;

import com.tripan.app.admin.domain.dto.PlatformSettlementDto;
import com.tripan.app.admin.mapper.PlatformSettlementMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class PlatformSettlementServiceImpl implements PlatformSettlementService {

    private final PlatformSettlementMapper mapper;

    @Override
    public PlatformSettlementDto.PageResponse getPageData(int year, String month) {
        log.info("[PlatformSettlement] 조회 year={}, month={}", year, month);

        // KPI
        PlatformSettlementDto.KpiDto kpi = mapper.selectKpi(year, month);

        // 전월 GMV 트렌드 (월 단위 조회일 때만)
        if (month != null && !month.isBlank()) {
            Long prevGmv = mapper.selectPrevMonthGmv(year, month);
            long prev    = (prevGmv != null) ? prevGmv : 0L;
            double trendPct = (prev == 0) ? 0.0
                    : Math.round((kpi.getGmv() - prev) * 1000.0 / prev) / 10.0;
            kpi.setGmvTrendPct(trendPct);
            kpi.setPrevGmv(prev);
        }

        // 미정산 배너
        kpi.setPendingPartnerCount(mapper.selectPendingPartnerCount());
        Long pendingAmt = mapper.selectPendingAmount();
        kpi.setPendingAmount(pendingAmt != null ? pendingAmt : 0L);

        // 월별 정산 목록 (테이블)
        List<PlatformSettlementDto.MonthlyRowDto> monthlyList =
                mapper.selectMonthlyList(year, month);

        // 합계 행
        PlatformSettlementDto.MonthlyRowDto total = buildTotal(monthlyList);

        // 일별 차트 — month 없으면 현재 월 기준
        String chartMonth = (month != null && !month.isBlank())
                ? month
                : String.format("%02d", LocalDate.now().getMonthValue());
        List<PlatformSettlementDto.DailyChartDto> dailyChart =
                mapper.selectDailyChart(year, chartMonth);

        // 응답 조립
        PlatformSettlementDto.PageResponse response = new PlatformSettlementDto.PageResponse();
        response.setKpi(kpi);
        response.setMonthlyList(monthlyList);
        response.setTotal(total);
        response.setDailyChart(dailyChart);

        return response;
    }

    private PlatformSettlementDto.MonthlyRowDto buildTotal(
            List<PlatformSettlementDto.MonthlyRowDto> list) {

        PlatformSettlementDto.MonthlyRowDto total = new PlatformSettlementDto.MonthlyRowDto();
        total.setSettlementMonth("합계");
        long gmv = 0, payout = 0, comm = 0, coupon = 0, point = 0, profit = 0;
        for (PlatformSettlementDto.MonthlyRowDto row : list) {
            gmv    += row.getGmv();
            payout += row.getPartnerPayout();
            comm   += row.getCommission();
            coupon += row.getCouponDiscount();
            point  += row.getPointUsed();
            profit += row.getNetProfit();
        }
        total.setGmv(gmv);
        total.setPartnerPayout(payout);
        total.setCommission(comm);
        total.setCouponDiscount(coupon);
        total.setPointUsed(point);
        total.setNetProfit(profit);
        return total;
    }
}