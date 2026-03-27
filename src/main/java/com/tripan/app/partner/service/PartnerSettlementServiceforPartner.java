package com.tripan.app.partner.service;

import java.util.List;
import java.util.Map;

public interface PartnerSettlementServiceforPartner {
    
    Map<String, Object> getExpectedSettlement(Long partnerId);
    List<Map<String, Object>> getSettlementList(Long partnerId, String settleMonth, String status);
}