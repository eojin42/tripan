package com.tripan.app.partner.service;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;

import com.tripan.app.partner.mapper.PartnerSettlementMapperforPartner;

import lombok.RequiredArgsConstructor;


@Service("partnerSiteSettlementServiceforPartner")
@RequiredArgsConstructor
public class PartnerSettlementServiceImplforPartner implements PartnerSettlementServiceforPartner {

    private final PartnerSettlementMapperforPartner partnerSettlementMapperforPartner;

    @Override
    public Map<String, Object> getExpectedSettlement(Long partnerId) {
        String currentMonth = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy-MM"));
        
        return partnerSettlementMapperforPartner.selectExpectedSettlement(partnerId, currentMonth);
    }

    @Override
    public List<Map<String, Object>> getSettlementList(Long partnerId, String settleMonth, String status) {
        Map<String, Object> params = new HashMap<>();
        params.put("partnerId", partnerId);
        params.put("settleMonth", settleMonth);
        params.put("status", status);

        return partnerSettlementMapperforPartner.selectSettlementList(params);
    }
    
    @Override
    public List<Map<String, Object>> getSettlementDetailList(Long partnerId, String month) {
        return partnerSettlementMapperforPartner.selectSettlementDetailList(partnerId, month);
    }
} 