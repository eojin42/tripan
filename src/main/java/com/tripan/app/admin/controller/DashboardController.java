package com.tripan.app.admin.controller;

import com.tripan.app.admin.domain.dto.DashboardDto;
import com.tripan.app.admin.service.DashboardService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.Map;

@Slf4j
@Controller
@RequiredArgsConstructor
@RequestMapping("/admin")
public class DashboardController {

    private final DashboardService dashboardService;

    /** 대시보드 페이지 */
    @GetMapping({"/main", "/", ""})
    public String home() {
        return "admin/main/home";
    }

    /**
     * 대시보드 데이터 API
     * GET /admin/dashboard/data
     */
    @GetMapping("/dashboard/data")
    @ResponseBody
    public ResponseEntity<?> getDashboardData() {
        try {
            DashboardDto.PageResponse data = dashboardService.getDashboardData();
            return ResponseEntity.ok(data);
        } catch (Exception e) {
            log.error("[Dashboard] 데이터 조회 실패", e);
            return ResponseEntity.internalServerError()
                    .body(Map.of("success", false, "message", "데이터 조회에 실패했습니다."));
        }
    }
}