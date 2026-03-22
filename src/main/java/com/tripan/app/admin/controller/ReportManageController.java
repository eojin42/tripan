package com.tripan.app.admin.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.tripan.app.admin.domain.dto.ReportManageDto;
import com.tripan.app.admin.mapper.ReportManageMapper;
import com.tripan.app.admin.service.ReportManageService;

import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/admin/report")
@RequiredArgsConstructor
public class ReportManageController {

    private final ReportManageService reportManageService;
    private final ObjectMapper        objectMapper;
    private final ReportManageMapper reportMapper;

    // ─────────────────────────────────────────
    //  신고 관리 메인 페이지
    // ─────────────────────────────────────────
    @GetMapping("/main")
    public String main(@RequestParam(value = "targetType", required = false) String targetType,Model model) throws Exception {
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

    // ─────────────────────────────────────────
    //  콘텐츠 활성화 API
    //  POST /admin/report/activate
    // ─────────────────────────────────────────
    @PostMapping("/activate")
    @ResponseBody
    public ResponseEntity<?> activate(@RequestBody Map<String, Object> body) {
        try {
            String targetType = (String) body.get("targetType");
            Long   targetId   = Long.valueOf(body.get("targetId").toString());
            reportManageService.activateContent(targetType, targetId);
            return ResponseEntity.ok(Map.of("success", true));
        } catch (Exception e) {
            return ResponseEntity.ok(Map.of("success", false, "message", e.getMessage()));
        }
    }
    
    /**
     * GET /admin/report/content?targetType=FEED&targetId=1
     * 글 본문 + 댓글 목록 반환
     * { content: "글내용", comments: [{commentId, nickname, content}] }
     */
    @GetMapping("/content")
    public ResponseEntity<Map<String, Object>> getContent(
            @RequestParam("targetType") String targetType,
            @RequestParam("targetId")   Long targetId) {
 
        Map<String, Object> result = new HashMap<>();
 
        switch (targetType) {
            case "FEED": {
                String content  = reportMapper.selectFeedContent(targetId);
                List<Map<String,Object>> comments = reportMapper.selectFeedComments(targetId);
                result.put("content",  content  != null ? content : "");
                result.put("comments", comments);
                break;
            }
            case "FEED_COMMENT": {
                Long postId = reportMapper.selectFeedPostIdByCommentId(targetId);
                if (postId != null) {
                    String content = reportMapper.selectFeedContent(postId);
                    List<Map<String,Object>> comments = reportMapper.selectFeedComments(postId);
                    result.put("content",  content != null ? content : "");
                    result.put("comments", comments);
                } else {
                    result.put("content", ""); result.put("comments", List.of());
                }
                break;
            }
            case "FREEBOARD": {
                String content  = reportMapper.selectFreeboardContent(targetId);
                List<Map<String,Object>> comments = reportMapper.selectFreeboardComments(targetId);
                result.put("content",  content  != null ? content : "");
                result.put("comments", comments);
                break;
            }
            case "FREEBOARD_COMMENT": {
                Long boardId = reportMapper.selectFreeboardIdByCommentId(targetId);
                if (boardId != null) {
                    String content = reportMapper.selectFreeboardContent(boardId);
                    List<Map<String,Object>> comments = reportMapper.selectFreeboardComments(boardId);
                    result.put("content",  content != null ? content : "");
                    result.put("comments", comments);
                } else {
                    result.put("content", ""); result.put("comments", List.of());
                }
                break;
            }
            case "MATE": {
                String content  = reportMapper.selectMateContent(targetId);
                List<Map<String,Object>> comments = reportMapper.selectMateComments(targetId);
                result.put("content",  content  != null ? content : "");
                result.put("comments", comments);
                break;
            }
            case "MATE_COMMENT": {
                Long mateId = reportMapper.selectMateIdByCommentId(targetId);
                if (mateId != null) {
                    String content = reportMapper.selectMateContent(mateId);
                    List<Map<String,Object>> comments = reportMapper.selectMateComments(mateId);
                    result.put("content",  content != null ? content : "");
                    result.put("comments", comments);
                } else {
                    result.put("content", ""); result.put("comments", List.of());
                }
                break;
            }
            default:
                result.put("content",  "");
                result.put("comments", List.of());
        }
 
        return ResponseEntity.ok(result);
    }
}