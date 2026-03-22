package com.tripan.app.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.tripan.app.domain.dto.ReportDto;

@Mapper
public interface ReportMapper {
    void insertReport(ReportDto dto);
    
    int countReportByTarget(@Param("targetType") String targetType, @Param("targetId") Long targetId);
    int countReportByReportedId(Long reportedId);
    
    int checkDuplicateReport(ReportDto reportDto);
    
}