package com.tripan.app.mapper;

import org.apache.ibatis.annotations.Mapper;
import com.tripan.app.domain.dto.ReportDto;

@Mapper
public interface ReportMapper {
    void insertReport(ReportDto dto);
}