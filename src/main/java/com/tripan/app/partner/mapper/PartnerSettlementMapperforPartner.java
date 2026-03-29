package com.tripan.app.partner.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

@Mapper
public interface PartnerSettlementMapperforPartner {
    
    Map<String, Object> selectExpectedSettlement(@Param("partnerId") Long partnerId, @Param("month") String month);

    List<Map<String, Object>> selectSettlementList(Map<String, Object> params);
    
    List<Map<String, Object>> selectSettlementDetailList(@Param("partnerId") Long partnerId, @Param("month") String month);
    
}