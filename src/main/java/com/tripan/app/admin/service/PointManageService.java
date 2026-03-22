package com.tripan.app.admin.service;

import com.tripan.app.admin.domain.dto.PointManageDto;

import java.util.List;

public interface PointManageService {

    /* 회원별 포인트 요약 목록 */
    List<PointManageDto> getMemberPointList(PointManageDto.SearchRequest request);

    /* 개인 포인트 내역 */
    List<PointManageDto.HistoryDto> getPointHistory(Long memberId,
                                                     String startDate,
                                                     String endDate);

    /* 포인트 지급/차감 (개인 or 일괄) */
    void adjustPoints(PointManageDto.AdjustRequest request);
}