package com.tripan.app.admin.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.tripan.app.admin.domain.dto.ReportManageDto;
import com.tripan.app.admin.service.ReportManageService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/admin/report")
@RequiredArgsConstructor
public class ReportManageController {

    private final ReportManageService reportManageService;
    private final ObjectMapper        objectMapper;

    // ─────────────────────────────────────────
    //  신고 관리 메인 페이지
    // ─────────────────────────────────────────
    @GetMapping("/main")
    public String main(
            @RequestParam(value = "targetType", required = false) String targetType,
            Model model
    ) throws Exception {
        List<ReportManageDto> contentList  = reportManageService.getContentList(targetType);
        List<ReportManageDto>  userList     = reportManageService.getUserReportList();

        model.addAttribute("contentListJson", objectMapper.writeValueAsString(contentList));
        model.addAttribute("userListJson",    objectMapper.writeValueAsString(userList));
        model.addAttribute("targetType",      targetType);
        return "admin/report/main";
    }

    // ─────────────────────────────────────────
    //  콘텐츠 비활성화 API
    //  POST /admin/report/deactivate
    // ─────────────────────────────────────────
    @PostMapping("/deactivate")
    @ResponseBody
    public ResponseEntity<?> deactivate(@RequestBody Map<String, Object> body) {
        try {
            String targetType = (String) body.get("targetType");
            Long   targetId   = Long.valueOf(body.get("targetId").toString());
            reportManageService.deactivateContent(targetType, targetId);
            return ResponseEntity.ok(Map.of("success", true));
        } catch (Exception e) {
            return ResponseEntity.ok(Map.of("success", false, "message", e.getMessage()));
        }
    }
}