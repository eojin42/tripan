package com.tripan.app.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.tripan.app.domain.dto.ExpenseDto;

@Mapper
public interface ExpenseMapper {
	
	// 총 지출액 단일 조회 
    Double selectTotalExpenseAmount(@Param("tripId") Long tripId);
    
    // 전체 지출 요약 (총액 및 1인당 평균)
    Map<String, Object> selectExpenseSummary(@Param("tripId") Long tripId);

    // 카테고리별 통계 (식당/숙소/교통 등)
    List<Map<String, Object>> selectExpenseStatsByCategory(@Param("tripId") Long tripId);

    // 지출 내역 상세 목록 (본인 참여분 포함)
    List<ExpenseDto> selectExpenseList(@Param("tripId") Long tripId, @Param("myMemberId") Long myMemberId);
}