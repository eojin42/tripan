package com.tripan.app.partner.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;
import java.util.Map;

@Mapper
public interface PartnerStatsMapper {
    
    Map<String, Object> selectMonthlySummary(@Param("partnerId") Long partnerId, @Param("month") String month);
    
    List<Map<String, Object>> selectDailySales(@Param("partnerId") Long partnerId, @Param("month") String month);
    
    List<Map<String, Object>> selectRoomSales(@Param("partnerId") Long partnerId, @Param("month") String month);
}