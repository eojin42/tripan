package com.tripan.app.admin.mapper;

import com.tripan.app.admin.domain.dto.PointManageDto;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface PointManageMapper {

    /* ── 회원별 포인트 요약 목록 ── */
    List<PointManageDto> selectMemberPointList(
            @Param("keyword")   String keyword,
            @Param("startDate") String startDate,
            @Param("endDate")   String endDate
    );

    /* ── 개인 포인트 내역 ── */
    List<PointManageDto.HistoryDto> selectPointHistory(
            @Param("memberId")  Long memberId,
            @Param("startDate") String startDate,
            @Param("endDate")   String endDate
    );

    /* ── 현재 잔여 포인트 조회 ── */
    Integer selectRemPoint(@Param("memberId") Long memberId);

    /* ── 포인트 내역 INSERT ── */
    int insertPointHistory(
            @Param("memberId")     Long memberId,
            @Param("orderId")      String orderId,
            @Param("changeReason") String changeReason,
            @Param("pointAmount")  int pointAmount,
            @Param("remPoint")     int remPoint
    );
}