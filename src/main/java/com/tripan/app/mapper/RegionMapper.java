package com.tripan.app.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.tripan.app.domain.dto.RegionDto;

@Mapper
public interface RegionMapper {
    
    /**
     * API에서 가져온 지역 정보를 DB에 저장하거나 업데이트합니다.
     * MERGE INTO 구문 사용
     */
    void upsertRegion(
        @Param("sidoName") String sidoName,
        @Param("sigunguName") String sigunguName,
        @Param("apiAreaCode") Integer apiAreaCode,
        @Param("apiSigunguCode") Integer apiSigunguCode
    );
    List<RegionDto> selectSidoList();
}