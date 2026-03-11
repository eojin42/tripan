package com.tripan.app.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.tripan.app.domain.dto.ExpenseDto;

@Mapper
public interface ExpenseMapper {
    
    // 총 지출액 조회 
    Integer selectTotalExpenseAmount(@Param("tripId") Long tripId);

    // 카테고리별 통계 
    List<Map<String, Object>> selectExpenseStatsByCategory(@Param("tripId") Long tripId);

    // 지출 목록 상세 조회 
    List<ExpenseDto> selectExpenseList(@Param("tripId") Long tripId, @Param("myMemberId") Long myMemberId);
}