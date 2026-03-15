package com.tripan.app.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.tripan.app.domain.dto.CommunityFeedListDto;
import com.tripan.app.domain.dto.CommunityFeedWriteRequestDto;
import com.tripan.app.domain.dto.MemberDto;
import com.tripan.app.service.CommunityFeedService;

import jakarta.servlet.http.HttpSession;

@RestController
@RequestMapping("/api/feed")
public class CommunityFeedApiController {

    @Autowired
    private CommunityFeedService feedService;

    @PostMapping("/write")
    public Map<String, Object> writeFeed(
            @ModelAttribute CommunityFeedWriteRequestDto requestDTO, 
            HttpSession session) {
        
        Map<String, Object> response = new HashMap<>();

        MemberDto loginUser = (MemberDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            response.put("status", "error");
            response.put("message", "로그인이 필요합니다.");
            return response;
        }

        try {
            feedService.insertFeed(requestDTO, loginUser.getMemberId());
            
            response.put("status", "success");
        } catch (Exception e) {
            e.printStackTrace();
            response.put("status", "error");
            response.put("message", "서버 오류가 발생했습니다.");
        }
        return response;
    }
    

    
}