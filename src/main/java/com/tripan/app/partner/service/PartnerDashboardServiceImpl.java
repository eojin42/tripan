package com.tripan.app.partner.service;

import java.util.HashMap;
import java.util.Map;

import org.springframework.stereotype.Service;

import com.tripan.app.partner.mapper.PartnerDashboardMapper;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class PartnerDashboardServiceImpl implements PartnerDashboardService {

    private final PartnerDashboardMapper partnerDashboardMapper;

    @Override
    public Map<String, Object> getDashboardData(Long partnerId) {
        Map<String, Object> dashboardData = new HashMap<>();

        Map<String, Object> kpiData = partnerDashboardMapper.selectTodayDashboardKpi(partnerId);
        if (kpiData != null) {
            dashboardData.putAll(kpiData);
        }

        Map<String, Object> todoSalesData = partnerDashboardMapper.selectTodoAndSalesKpi(partnerId);
        if (todoSalesData != null) {
            dashboardData.putAll(todoSalesData);
        }

        dashboardData.putIfAbsent("checkInTotal", 0);
        dashboardData.putIfAbsent("checkOutTotal", 0);
        dashboardData.putIfAbsent("newReserveTotal", 0);
        dashboardData.putIfAbsent("unreadReviewCount", 0);
        dashboardData.putIfAbsent("thisMonthSales", 0);

        return dashboardData;
    }
}