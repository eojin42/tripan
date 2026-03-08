package com.tripan.app.mapper;

import com.tripan.app.domain.dto.CommunityMateDto;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;

@Mapper
public interface CommunityMateMapper {
    
    List<CommunityMateDto> selectMateList(
        @Param("regionId") Long regionId,
        @Param("startDate") String startDate,
        @Param("endDate") String endDate,
        @Param("searchTag") String searchTag
    );

    void insertMate(CommunityMateDto dto);
    CommunityMateDto selectMateById(Long mateId);
}