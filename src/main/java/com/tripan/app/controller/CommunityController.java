package com.tripan.app.controller;

import java.util.List;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.tripan.app.config.WebSocketEventListener;
import com.tripan.app.domain.dto.CommunityChatRoomDto;
import com.tripan.app.domain.dto.CommunityFreeBoardDto;
import com.tripan.app.domain.dto.CommunityFreeboardCommentDto;
import com.tripan.app.domain.dto.MemberDto;
import com.tripan.app.domain.dto.SessionInfo;
import com.tripan.app.service.CommunityChatService;
import com.tripan.app.service.CommunityFreeboardService;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
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
 
    @GetMapping("/freeboard/detail/{boardId}")
    public String handleFreeboardDetail(@PathVariable("boardId") Long boardId, 
                                        @RequestParam(value="updateView", defaultValue="true") boolean updateView, // 🌟 추가
                                        HttpServletRequest request, Model model, HttpSession session) {
        
        String requestedWith = request.getHeader("X-Requested-With");
        if ("Fetch".equals(requestedWith) || "XMLHttpRequest".equals(requestedWith)) {
            
            // 🌟 수정: updateView 값 전달
            CommunityFreeBoardDto board = freeboardService.getBoardDetail(boardId, updateView);
            List<CommunityFreeboardCommentDto> comments = freeboardService.getCommentList(boardId);
            
            MemberDto loginUser = (MemberDto) session.getAttribute("loginUser");
            int isLiked = 0;
            if (loginUser != null) {
                isLiked = freeboardService.checkLikeStatus(boardId, loginUser.getMemberId());
            }
            
            model.addAttribute("board", board);
            model.addAttribute("comments", comments);
            model.addAttribute("isLiked", isLiked); 
            
            return "community/fragment/freeboard_detail"; 
        }
        return "redirect:/community/freeboard";
    }
    
    /**
     * 🌟 자유게시판 댓글 등록 (AJAX)
     */
    @PostMapping("/freeboard/comment/add")
    @ResponseBody
    public ResponseEntity<?> addFreeboardComment(@RequestBody CommunityFreeboardCommentDto commentDto) {
        try {
            // 실제 로그인 연동 시 세션에서 memberId를 가져와 세팅해야 함
            // 임시로 memberId = 1 로 고정 테스트 (나중에 수정 필요)
            if (commentDto.getMemberId() == null) {
                commentDto.setMemberId(1L); 
            }
            
            freeboardService.registerComment(commentDto);
            
            // 등록 성공 메시지 반환
            return ResponseEntity.ok(Map.of("status", "success", "message", "댓글이 등록되었습니다."));
        } catch (Exception e) {
            log.error("댓글 등록 실패", e);
            return ResponseEntity.status(500).body(Map.of("status", "error", "message", "등록 중 오류가 발생했습니다."));
        }
    }
    
    @PostMapping("/freeboard/like/{boardId}")
    @ResponseBody
    public ResponseEntity<?> handleLike(@PathVariable("boardId") Long boardId, HttpSession session) {
        MemberDto loginUser = (MemberDto) session.getAttribute("loginUser");
        
        if (loginUser == null) {
            return ResponseEntity.status(401).build(); 
        }

        try {
            Map<String, Object> result = freeboardService.toggleLike(boardId, loginUser.getMemberId());
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            log.error("좋아요 처리 에러", e);
            return ResponseEntity.status(500).build();
        }
    }
    
    
    @GetMapping("/chat/openlounge")
    public String openlounge(Model model) {
        
        return "community/chat/openlounge"; 
    }
}