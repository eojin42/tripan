package com.tripan.app.partner.service;

import java.time.YearMonth;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

import com.tripan.app.partner.mapper.PartnerStatsMapper;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class PartnerStatsServiceImpl implements PartnerStatsService {

    private final PartnerStatsMapper partnerStatsMapper;

    @Override
    public Map<String, Object> getStatsData(Long partnerId, String month) {
        Map<String, Object> response = new HashMap<>();

        Map<String, Object> summary = partnerStatsMapper.selectMonthlySummary(partnerId, month);
        if (summary != null) {
            response.put("totalSales", summary.get("totalSales"));
            response.put("totalCount", summary.get("totalCount"));
        } else {
            response.put("totalSales", 0);
            response.put("totalCount", 0);
        }

        List<Map<String, Object>> dailySales = partnerStatsMapper.selectDailySales(partnerId, month);
        
        Map<String, Long> dailySalesMap = new HashMap<>();
        for (Map<String, Object> daily : dailySales) {
            String dateStr = (String) daily.get("salesDate");
            Long sales = ((Number) daily.get("dailySales")).longValue();
            dailySalesMap.put(dateStr, sales);
        }

        YearMonth yearMonth = YearMonth.parse(month); // "YYYY-MM"
        int lengthOfMonth = yearMonth.lengthOfMonth();
        
        List<String> dailyLabels = new ArrayList<>();
        List<Long> dailyValues = new ArrayList<>();

        for (int day = 1; day <= lengthOfMonth; day++) {
            String currentDateStr = month + "-" + String.format("%02d", day);
            dailyLabels.add(day + "일"); 
            dailyValues.add(dailySalesMap.getOrDefault(currentDateStr, 0L)); // 없으면 0원
        }
        response.put("dailyLabels", dailyLabels);
        response.put("dailyValues", dailyValues);

        List<Map<String, Object>> roomSales = partnerStatsMapper.selectRoomSales(partnerId, month);
        List<String> roomLabels = roomSales.stream()
                .map(r -> (String) r.get("roomName"))
                .collect(Collectors.toList());
        List<Long> roomValues = roomSales.stream()
                .map(r -> ((Number) r.get("roomSales")).longValue())
                .collect(Collectors.toList());
                
        response.put("roomLabels", roomLabels);
        response.put("roomValues", roomValues);

        return response;
    }
}