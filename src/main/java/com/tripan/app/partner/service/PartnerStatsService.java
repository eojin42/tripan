package com.tripan.app.partner.service;

import java.util.Map;

public interface PartnerStatsService {
    
    Map<String, Object> getStatsData(Long partnerId, String month);
    
}