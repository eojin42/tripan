package com.tripan.app.controller;

import java.util.HashMap;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.tripan.app.domain.dto.MemberDto;
import com.tripan.app.domain.dto.ReportDto;
import com.tripan.app.service.ReportService;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@RestController
@RequestMapping("/api/report")
@RequiredArgsConstructor
public class ReportApiController {

    private final ReportService reportService;

    @PostMapping("/submit")
    public ResponseEntity<Map<String, Object>> submitReport(
            @RequestBody ReportDto reportDto, 
            HttpSession session) {
        
        Map<String, Object> response = new HashMap<>();

        MemberDto loginUser = (MemberDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            response.put("status", "error");
            response.put("message", "로그인이 필요합니다.");
            return ResponseEntity.status(401).body(response);
        }

        try {
            reportDto.setReporterId(loginUser.getMemberId());
            
            reportService.submitReport(reportDto);

            response.put("status", "success");
            response.put("message", "신고가 정상적으로 접수되었습니다.");
            return ResponseEntity.ok(response);
            
        } catch (IllegalArgumentException e) {
            response.put("status", "error");
            response.put("message", e.getMessage()); 
            return ResponseEntity.badRequest().body(response); 

        } catch (Exception e) {
            log.error("신고 접수 중 에러 발생", e);
            response.put("status", "error");
            response.put("message", "서버 오류가 발생했습니다.");
            return ResponseEntity.status(500).body(response);
        }
    }
}