package com.tripan.app.partner.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.Map;

@Mapper
public interface PartnerDashboardMapper {
    
    Map<String, Object> selectTodayDashboardKpi(@Param("partnerId") Long partnerId);
    
    Map<String, Object> selectTodoAndSalesKpi(@Param("partnerId") Long partnerId);

}