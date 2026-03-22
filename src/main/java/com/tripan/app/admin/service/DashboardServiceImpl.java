package com.tripan.app.admin.service;

import com.tripan.app.admin.domain.dto.DashboardDto;
import com.tripan.app.admin.mapper.DashboardMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class DashboardServiceImpl implements DashboardService {

    private final DashboardMapper mapper;

    @Override
    public DashboardDto.PageResponse getDashboardData() {
        log.info("[Dashboard] 대시보드 데이터 조회");
 
        DashboardDto.PageResponse response = new DashboardDto.PageResponse();
        response.setDailyOrders(mapper.selectDailyOrders());
        response.setAccomRanking(mapper.selectAccomRanking());
        response.setRegionRanking(mapper.selectRegionRanking());
        // 미답변 채팅은 /admin/cs/api/chat/rooms/support 를 JSP에서 직접 호출
        response.setPendingPartners(mapper.selectPendingPartners());
        response.setTopReported(mapper.selectTopReported());
        return response;
    }
}