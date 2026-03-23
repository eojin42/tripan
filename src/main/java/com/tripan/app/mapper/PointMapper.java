package com.tripan.app.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.tripan.app.domain.dto.PointDto;

@Mapper
public interface PointMapper {
	Long getLatestPoint(Long memberId);
    
    void insertPoint(PointDto pointDto);
    
    /** 전체 포인트 내역 조회 (최신순) */
    List<PointDto> selectPointList(@Param("memberId") Long memberId);
 
    /** 이번 달 적립 합계 (point_amount > 0) */
    int selectMonthEarn(@Param("memberId") Long memberId);
 
    /** 이번 달 사용 합계 (point_amount < 0, 절댓값 반환) */
    int selectMonthUse(@Param("memberId") Long memberId);
}
