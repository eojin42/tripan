package com.tripan.app.admin.service;

import com.tripan.app.admin.domain.dto.PlatformSettlementDto;

public interface PlatformSettlementService {

    /**
     *
     * @param year  조회 연도 (예: 2026)
     * @param month 조회 월 (예: "03"), null 이면 연간 전체
     * @return KPI + 월별 목록 + 합계 행
     */
    PlatformSettlementDto.PageResponse getPageData(int year, String month);
}