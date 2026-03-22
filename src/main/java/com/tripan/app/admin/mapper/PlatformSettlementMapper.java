package com.tripan.app.admin.mapper;

import com.tripan.app.admin.domain.dto.PlatformSettlementDto;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface PlatformSettlementMapper {

    PlatformSettlementDto.KpiDto selectKpi(
            @Param("year")  int    year,
            @Param("month") String month
    );

    Long selectPrevMonthGmv(
            @Param("year")  int    year,
            @Param("month") String month
    );

    List<PlatformSettlementDto.MonthlyRowDto> selectMonthlyList(
            @Param("year")  int    year,
            @Param("month") String month
    );

    /** 일별 수익 추이 차트용 — month 필수 */
    List<PlatformSettlementDto.DailyChartDto> selectDailyChart(
            @Param("year")  int    year,
            @Param("month") String month
    );

    int  selectPendingPartnerCount();
    Long selectPendingAmount();
}