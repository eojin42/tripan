package com.tripan.app.controller;

import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import com.tripan.app.config.WebSocketEventListener;
import com.tripan.app.domain.dto.CommunityChatRoomDto;
import com.tripan.app.domain.dto.CommunityFreeBoardDto;
import com.tripan.app.service.CommunityChatService;
import com.tripan.app.service.CommunityFreeboardService;

import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Controller
@RequestMapping("/community")
@RequiredArgsConstructor
@Slf4j
public class CommunityController {
	
	private final CommunityFreeboardService freeboardService;
	private final CommunityChatService chatService;

    @GetMapping({"", "/", "/feed"})
    public String handleCommunityFeed(Model model) {

    	return "community/feed";
    	
    }

    @GetMapping("/freeboard")
    public String handleCommunityFreeboard(Model model) {

    	model.addAttribute("activeTab", "freeboard");
    	
        return "community/feed"; 
    }

    @GetMapping("/fragment/{tabType}")
    public String handleFragment(@PathVariable("tabType") String tabType, HttpServletRequest request, Model model) {
        String requestedWith = request.getHeader("X-Requested-With");
        
        if ("Fetch".equals(requestedWith) || "XMLHttpRequest".equals(requestedWith)) {
            
            if ("freeboard".equals(tabType)) {
                List<CommunityFreeBoardDto> list = freeboardService.getBoardList();
                model.addAttribute("boardList", list);
                log.info("자유게시판 목록 조회 완료: {}건", list.size());
            }
            
            return "community/fragment/" + tabType + "_list"; 
        }
        else {
            if ("freeboard".equals(tabType)) {
                return "redirect:/community/freeboard";
            }
            return "redirect:/community/feed?tab=" + tabType;
        }
    }
    
    /**
     * 🌟 실시간 인기 지역 톡 상위 3개 API
     * @ResponseBody를 붙여 JSON 데이터를 반환합니다.
     */
    @GetMapping("/api/chat/top-rooms")
    @ResponseBody
    public List<CommunityChatRoomDto> getTopChatRooms() {
        List<CommunityChatRoomDto> topRooms = chatService.getTopChatRooms();
        log.info("실시간 인기 채팅방 조회 완료: {}건", topRooms.size());
        return topRooms;
    }
    
    @GetMapping("/chat/openlounge")
    public String openlounge(Model model) {
        
        return "community/chat/openlounge"; 
    }
}