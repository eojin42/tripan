package com.tripan.app.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.tripan.app.config.WebSocketEventListener;
import com.tripan.app.domain.dto.CommunityChatRoomDto;
import com.tripan.app.domain.dto.CommunityFeedListDto;
import com.tripan.app.domain.dto.CommunityFeedWriteRequestDto;
import com.tripan.app.domain.dto.CommunityFreeBoardDto;
import com.tripan.app.domain.dto.CommunityFreeboardCommentDto;
import com.tripan.app.domain.dto.CommunityMateCommentDto;
import com.tripan.app.domain.dto.CommunityMateDto;
import com.tripan.app.domain.dto.MemberDto;
import com.tripan.app.domain.dto.SessionInfo;
import com.tripan.app.mapper.CommunityMateCommentMapper;
import com.tripan.app.service.CommunityChatService;
import com.tripan.app.service.CommunityFeedService;
import com.tripan.app.service.CommunityFreeboardService;
import com.tripan.app.service.CommunityMateService;

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
	private final CommunityMateService mateService;
    private final CommunityMateCommentMapper mateCommentMapper;
    private final CommunityFeedService feedService;

    @GetMapping({"", "/", "/feed"})
    public String handleCommunityFeed(Model model, HttpSession session) {
    	MemberDto loginUser = (MemberDto) session.getAttribute("loginUser");
        Long loginId = (loginUser != null) ? loginUser.getMemberId() : -1L;

        List<CommunityFeedListDto> feedList = feedService.getFeedList(loginId); 
        model.addAttribute("feedList", feedList);
        return "community/feed";
    }

    @GetMapping("/freeboard")
    public String handleCommunityFreeboard(Model model) {

    	model.addAttribute("activeTab", "freeboard");
    	
        return "community/feed"; 
    }

    @GetMapping("/fragment/{tabType}")
    public String handleFragment(@PathVariable("tabType") String tabType, HttpServletRequest request, Model model, HttpSession session) {
        String requestedWith = request.getHeader("X-Requested-With");
        
        if ("Fetch".equals(requestedWith) || "XMLHttpRequest".equals(requestedWith)) {
            
            if ("freeboard".equals(tabType)) {
                List<CommunityFreeBoardDto> list = freeboardService.getBoardList();
                model.addAttribute("boardList", list);
                log.info("자유게시판 목록 조회 완료: {}건", list.size());
                
            } else if ("mate".equals(tabType)) {
                return "community/fragment/mate/mate_list"; 
                
            } else if ("feed".equals(tabType)) {
            	MemberDto loginUser = (MemberDto) session.getAttribute("loginUser");
                Long loginId = (loginUser != null) ? loginUser.getMemberId() : -1L;
                
                List<CommunityFeedListDto> feedList = feedService.getFeedList(loginId);
                model.addAttribute("feedList", feedList);            	
            }
            
            return "community/fragment/" + tabType + "_list"; 
        }
        else {
            if ("freeboard".equals(tabType)) {
                return "redirect:/community/freeboard";
            } else if ("mate".equals(tabType)) {
                return "redirect:/community/feed?tab=mate";
            }
            return "redirect:/community/feed?tab=" + tabType;
        }
    }
    
    @PostMapping("/api/feed/write")
    @ResponseBody 
    public ResponseEntity<Map<String, Object>> writeFeed(
            @ModelAttribute CommunityFeedWriteRequestDto requestDTO, 
            HttpSession session) {
        
        Map<String, Object> response = new HashMap<>();

        MemberDto loginUser = (MemberDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            response.put("status", "error");
            response.put("message", "로그인이 필요합니다.");
            return ResponseEntity.status(401).body(response);
        }

        try {
            feedService.insertFeed(requestDTO, loginUser.getMemberId());
            response.put("status", "success");
            response.put("message", "피드가 성공적으로 등록되었습니다!");
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            log.error("피드 등록 실패", e);
            response.put("status", "error");
            response.put("message", "서버 오류가 발생했습니다.");
            return ResponseEntity.status(500).body(response);
        }
    }
    
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
    
    @PostMapping("/mate/write")
    @ResponseBody
    public ResponseEntity<?> writeMatePost(@RequestBody CommunityMateDto dto, HttpSession session) {
        try {
        	MemberDto loginUser = (MemberDto) session.getAttribute("loginUser");

            if (loginUser == null) {
                return ResponseEntity.status(401).body(Map.of("status", "error", "message", "로그인이 필요합니다."));
            }

            dto.setMemberId(loginUser.getMemberId());

            mateService.registerMate(dto);
            return ResponseEntity.ok(Map.of("status", "success", "message", "동행 모집글이 성공적으로 등록되었습니다!"));
            
        } catch (Exception e) {
            log.error("동행 모집글 등록 에러", e);
            return ResponseEntity.status(500).body(Map.of("status", "error", "message", "서버 오류가 발생했습니다."));
        }
    }
    
    @GetMapping("/api/mate/list")
    @ResponseBody
    public ResponseEntity<List<CommunityMateDto>> getMateList(
            @RequestParam(value = "regionId", required = false) Long regionId,
            @RequestParam(value = "startDate", required = false) String startDate,
            @RequestParam(value = "endDate", required = false) String endDate,
            @RequestParam(value = "searchTag", required = false) String searchTag) {
        
        List<CommunityMateDto> list = mateService.getMateList(regionId, startDate, endDate, searchTag);
        return ResponseEntity.ok(list);
    }
    

    @PostMapping("/api/mate/comment/add")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> addMateComment(
            @RequestBody CommunityMateCommentDto dto, 
            HttpSession session) {
        
        Map<String, Object> response = new HashMap<>();
        MemberDto loginUser = (MemberDto) session.getAttribute("loginUser");
        
        if (loginUser == null) {
            response.put("status", "error");
            response.put("message", "로그인이 필요합니다.");
            return ResponseEntity.status(401).body(response);
        }
        
        dto.setMemberId(loginUser.getMemberId()); 
        mateService.registerMateComment(dto); 
        
        response.put("status", "success");
        response.put("message", "댓글이 등록되었습니다.");
        return ResponseEntity.ok(response);
    }

    @GetMapping("/api/mate/{mateId}/comments")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getMateComments(
            @PathVariable("mateId") Long mateId,
            @RequestParam(value = "page", defaultValue = "1") int page) {
        
        Map<String, Object> response = mateService.getMateComments(mateId, page);
        return ResponseEntity.ok(response);
    }
    
    @PostMapping("/api/mate/comment/delete/{commentId}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> deleteMateComment(
            @PathVariable("commentId") Long commentId, HttpSession session) {
        
        MemberDto loginUser = (MemberDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            return ResponseEntity.status(401).body(Map.of("status", "error", "message", "로그인이 필요합니다."));
        }
        
        boolean isDeleted = mateService.deleteMateComment(commentId, loginUser.getMemberId());
        
        if (isDeleted) {
            return ResponseEntity.ok(Map.of("status", "success", "message", "댓글이 삭제되었습니다."));
        } else {
            return ResponseEntity.status(403).body(Map.of("status", "error", "message", "삭제 권한이 없습니다."));
        }
    }    
    
    @PostMapping("/api/mate/{mateId}/status")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> changeMateStatus(
            @PathVariable("mateId") Long mateId,
            @RequestParam("status") String status,
            HttpSession session) {
        
        MemberDto loginUser = (MemberDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            return ResponseEntity.status(401).body(Map.of("status", "error", "message", "로그인이 필요합니다."));
        }
        
        boolean result = mateService.changeMateStatus(mateId, status, loginUser.getMemberId());
        
        if (result) {
            return ResponseEntity.ok(Map.of("status", "success", "message", "상태가 변경되었습니다."));
        } else {
            return ResponseEntity.status(403).body(Map.of("status", "error", "message", "권한이 없습니다."));
        }
    }
    
    @PostMapping("/api/follow/{targetId}")
    @ResponseBody
    public ResponseEntity<?> followToggle(@PathVariable("targetId") Long targetId, HttpSession session) {
        MemberDto loginUser = (MemberDto) session.getAttribute("loginUser");
        if (loginUser == null) return ResponseEntity.status(401).build();

        String result = feedService.toggleFollow(loginUser.getMemberId(), targetId);
        return ResponseEntity.ok(Map.of("status", result));
    }

}