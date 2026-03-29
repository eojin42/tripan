package com.tripan.app.partner.service;

import java.util.Map;

public interface PartnerDashboardService {
    Map<String, Object> getDashboardData(Long partnerId);
}