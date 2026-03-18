package com.tripan.app.mapper;

import org.apache.ibatis.annotations.Mapper;

import com.tripan.app.domain.dto.PointDto;

@Mapper
public interface PointMapper {
	Long getLatestPoint(Long memberId);
    
    void insertPoint(PointDto pointDto);
}
