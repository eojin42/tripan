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
    void updateMateStatus(@Param("mateId") Long mateId, @Param("status") String status);
    
    List<CommunityMateDto> getUserMateList(Long memberId);
    void updateMateViewCount(Long mateId);

    void deleteMatePost(Long mateId);
}