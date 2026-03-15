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
import org.springframework.web.bind.annotation.RestController;

import com.tripan.app.domain.dto.CommunityChatRoomDto;
import com.tripan.app.domain.dto.CommunityFeedCommentDto;
import com.tripan.app.domain.dto.CommunityFeedListDto;
import com.tripan.app.domain.dto.CommunityFeedWriteRequestDto;
import com.tripan.app.domain.dto.CommunityFreeBoardDto;
import com.tripan.app.domain.dto.CommunityFreeboardCommentDto;
import com.tripan.app.domain.dto.CommunityMateCommentDto;
import com.tripan.app.domain.dto.CommunityMateDto;
import com.tripan.app.domain.dto.MemberDto;
import com.tripan.app.mapper.CommunityMateCommentMapper;
import com.tripan.app.repository.FollowRepository;
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
	
    @Autowired
    private FollowRepository followRepository;
    
	private final CommunityFreeboardService freeboardService;
	private final CommunityChatService chatService;
	private final CommunityMateService mateService;
    private final CommunityMateCommentMapper mateCommentMapper;
    private final CommunityFeedService feedService;


    @GetMapping({"", "/", "/feed"})
    public String handleCommunityFeed(Model model, HttpSession session) {
        MemberDto loginUser = (MemberDto) session.getAttribute("loginUser");
        
        if (loginUser != null) {
            Long myId = loginUser.getMemberId();
            
            int followerCount = followRepository.countByFollowingId(myId);
            int followingCount = followRepository.countByFollowerId(myId);
            int postCount = feedService.getMyFeedCount(myId);
            
            model.addAttribute("followerCount", followerCount);
            model.addAttribute("followingCount", followingCount);
            model.addAttribute("postCount", postCount);
        }

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
    public String handleFragment(@PathVariable("tabType") String tabType, 
                                 @RequestParam(value = "category", required = false, defaultValue = "all") String category,
                                 @RequestParam(value = "memberId", required = false) Long targetMemberId, // 🌟 1. 프로필 조회를 위해 파라미터 추가!
                                 HttpServletRequest request, Model model, HttpSession session) {
        
        String requestedWith = request.getHeader("X-Requested-With");
        
        if ("Fetch".equals(requestedWith) || "XMLHttpRequest".equals(requestedWith)) {
            
            if ("freeboard".equals(tabType)) {
                List<CommunityFreeBoardDto> list = freeboardService.getBoardList(category);
                model.addAttribute("boardList", list);
                log.info("자유게시판 목록 조회 완료: {}건, 카테고리: {}", list.size(), category); 
                
            } else if ("mate".equals(tabType)) {
                return "community/fragment/mate/mate_list"; 
                
            } else if ("feed".equals(tabType)) {
                MemberDto loginUser = (MemberDto) session.getAttribute("loginUser");
                Long loginId = (loginUser != null) ? loginUser.getMemberId() : -1L;
                
                List<CommunityFeedListDto> feedList = feedService.getFeedList(loginId);
                model.addAttribute("feedList", feedList);            	
            
            } else if ("profile".equals(tabType)) {
                if (targetMemberId == null) return "error/NotFound";

                MemberDto loginUser = (MemberDto) session.getAttribute("loginUser");
                Long loginId = (loginUser != null) ? loginUser.getMemberId() : -1L;

                MemberDto targetUser = feedService.getMemberInfo(targetMemberId); 
                
                int followerCount = followRepository.countByFollowingId(targetMemberId);
                int followingCount = followRepository.countByFollowerId(targetMemberId);
                int postCount = feedService.getMyFeedCount(targetMemberId);
                
                List<CommunityFeedListDto> userFeedList = feedService.getUserFeedList(targetMemberId, loginId);
                
                boolean isFollowing = false;
                if (loginUser != null && !loginId.equals(targetMemberId)) {
                     // TODO: 나중에 팔로우 여부 확인하는 서비스(예: followService.isFollowing)가 있다면 여기에 연결!
                }

                // 모델에 싹 담아주기
                model.addAttribute("targetUser", targetUser);
                model.addAttribute("followerCount", followerCount);
                model.addAttribute("followingCount", followingCount);
                model.addAttribute("postCount", postCount);
                model.addAttribute("feedList", userFeedList);
                model.addAttribute("isMyProfile", loginId.equals(targetMemberId));
                model.addAttribute("isFollowing", isFollowing);

                return "community/fragment/profile/profile"; 
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
    
    @PostMapping("/api/feed/like/{postId}")
    @ResponseBody
    public ResponseEntity<?> handleFeedLike(@PathVariable("postId") Long postId, HttpSession session) {
        MemberDto loginUser = (MemberDto) session.getAttribute("loginUser");
        
        if (loginUser == null) {
            return ResponseEntity.status(401).build(); 
        }

        try {
            Map<String, Object> result = feedService.toggleFeedLike(postId, loginUser.getMemberId());
            
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            log.error("피드 좋아요 처리 에러", e);
            return ResponseEntity.status(500).build();
        }
    }
    
    @PostMapping("/freeboard/like/{boardId}")
    @ResponseBody
    public ResponseEntity<?> handlefreeboardLike(@PathVariable("boardId") Long boardId, HttpSession session) {
        MemberDto loginUser = (MemberDto) session.getAttribute("loginUser");
        
        if (loginUser == null) {
            return ResponseEntity.status(401).build(); 
        }

        try {
            Map<String, Object> result = freeboardService.toggleLike(boardId, loginUser.getMemberId());
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            log.error("자유게시판 좋아요 처리 에러", e);
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
    
    /**
     * 💬 특정 피드의 댓글 목록 조회 API (비동기)
     */
    @GetMapping("/api/feed/{postId}/comments")
    @ResponseBody
    public ResponseEntity<List<CommunityFeedCommentDto>> getFeedComments(@PathVariable("postId") Long postId) {
        try {
            // Service를 통해 해당 피드의 댓글 목록을 가져옵니다.
            List<CommunityFeedCommentDto> comments = feedService.getFeedComments(postId);
            return ResponseEntity.ok(comments);
        } catch (Exception e) {
            log.error("피드 댓글 조회 실패", e);
            return ResponseEntity.status(500).build();
        }
    }

    /**
     * 💬 피드 댓글 등록 API (비동기)
     */
    @PostMapping("/api/feed/comment/add")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> addFeedComment(
            @RequestBody CommunityFeedCommentDto dto, 
            HttpSession session) {
        
        MemberDto loginUser = (MemberDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            return ResponseEntity.status(401).body(Map.of("status", "error", "message", "로그인이 필요합니다."));
        }
        
        try {
            dto.setMemberId(loginUser.getMemberId()); 
            
            feedService.insertFeedComment(dto);
            
            return ResponseEntity.ok(Map.of("status", "success", "message", "댓글이 등록되었습니다."));
            
        } catch (Exception e) {
            log.error("피드 댓글 등록 실패", e);
            return ResponseEntity.status(500).body(Map.of("status", "error", "message", "댓글 등록 중 서버 오류가 발생했습니다."));
        }
    }
    
    @PostMapping("/api/feed/comment/delete/{commentId}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> deleteFeedComment(@PathVariable("commentId") Long commentId, HttpSession session) {
        MemberDto loginUser = (MemberDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            return ResponseEntity.status(401).body(Map.of("status", "error", "message", "로그인이 필요합니다."));
        }
        
        try {
            boolean isDeleted = feedService.deleteFeedComment(commentId, loginUser.getMemberId());
            if (isDeleted) {
                return ResponseEntity.ok(Map.of("status", "success", "message", "댓글이 삭제되었습니다."));
            } else {
                return ResponseEntity.status(403).body(Map.of("status", "error", "message", "삭제 권한이 없습니다."));
            }
        } catch (Exception e) {
            log.error("댓글 삭제 에러", e);
            return ResponseEntity.status(500).body(Map.of("status", "error", "message", "서버 오류가 발생했습니다."));
        }
    }
    
    /**
     * 게시글 삭제 
     */
    @PostMapping("/api/feed/delete/{postId}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> deleteFeedPost(@PathVariable("postId") Long postId, HttpSession session) {
        
        MemberDto loginUser = (MemberDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            return ResponseEntity.status(401).body(Map.of("status", "error", "message", "로그인이 필요합니다."));
        }

        try {
            boolean isDeleted = feedService.deleteFeed(postId, loginUser.getMemberId());
            
            if (isDeleted) {
                return ResponseEntity.ok(Map.of("status", "success", "message", "게시글이 삭제되었습니다."));
            } else {
                return ResponseEntity.status(403).body(Map.of("status", "error", "message", "삭제 권한이 없거나 이미 삭제된 게시글입니다."));
            }
        } catch (Exception e) {
            log.error("게시글 삭제 중 에러 발생 (게시글 ID: {})", postId, e);
            return ResponseEntity.status(500).body(Map.of("status", "error", "message", "서버 오류가 발생했습니다."));
        }
    }
    
    /**
     * 자유게시판 글쓰기 
     */
    @PostMapping("/api/freeboard/write")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> writeFreeboardPost(
            @ModelAttribute CommunityFreeBoardDto dto, // FormData로 넘어오므로 @ModelAttribute 사용
            HttpSession session) {
        
        Map<String, Object> response = new HashMap<>();
        
        MemberDto loginUser = (MemberDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            response.put("status", "error");
            response.put("message", "로그인이 필요합니다.");
            return ResponseEntity.status(401).body(response);
        }

        try {
            dto.setMemberId(loginUser.getMemberId());
            
            freeboardService.registerBoard(dto);
            
            response.put("status", "success");
            response.put("message", "게시글이 성공적으로 등록되었습니다!");
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            log.error("자유게시판 글 등록 실패", e);
            response.put("status", "error");
            response.put("message", "서버 오류가 발생했습니다.");
            return ResponseEntity.status(500).body(response);
        }
    }
    
    /**
     * 자유게시판 게시글 삭제 API
     */
    @PostMapping("/api/freeboard/delete/{boardId}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> deleteFreeboardPost(@PathVariable("boardId") Long boardId, HttpSession session) {
        
        MemberDto loginUser = (MemberDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            return ResponseEntity.status(401).body(Map.of("status", "error", "message", "로그인이 필요합니다."));
        }

        try {
            boolean isDeleted = freeboardService.deleteBoard(boardId, loginUser.getMemberId());
            
            if (isDeleted) {
                return ResponseEntity.ok(Map.of("status", "success", "message", "게시글이 삭제되었습니다."));
            } else {
                return ResponseEntity.status(403).body(Map.of("status", "error", "message", "삭제 권한이 없거나 이미 삭제된 게시글입니다."));
            }
        } catch (Exception e) {
            log.error("자유게시판 게시글 삭제 중 에러 발생 (게시글 ID: {})", boardId, e);
            return ResponseEntity.status(500).body(Map.of("status", "error", "message", "서버 오류가 발생했습니다."));
        }
    }

    @PostMapping("/api/freeboard/comment/delete/{commentId}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> deleteFreeboardComment(
            @PathVariable("commentId") Long commentId, HttpSession session) {
        
        Map<String, Object> response = new HashMap<>();
        
        MemberDto loginUser = (MemberDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            response.put("status", "error");
            response.put("message", "로그인이 필요합니다.");
            return ResponseEntity.status(401).body(response);
        }

        try {
            boolean isDeleted = freeboardService.deleteComment(commentId, loginUser.getMemberId());
            
            if (isDeleted) {
                response.put("status", "success");
                response.put("message", "댓글이 삭제되었습니다.");
                return ResponseEntity.ok(response);
            } else {
                response.put("status", "error");
                response.put("message", "삭제 권한이 없거나 이미 삭제된 댓글입니다.");
                return ResponseEntity.status(403).body(response);
            }
        } catch (Exception e) {
            log.error("자유게시판 댓글 삭제 중 에러 발생 (댓글 ID: {})", commentId, e);
            response.put("status", "error");
            response.put("message", "서버 오류가 발생했습니다.");
            return ResponseEntity.status(500).body(response);
        }
    }
    
    /**
     * 🌟 자유게시판 글 1개 조회 
     */
    @GetMapping("/api/freeboard/{boardId}")
    @ResponseBody
    public ResponseEntity<CommunityFreeBoardDto> getFreeboardPost(@PathVariable("boardId") Long boardId) {
        // 조회수 증가 없이(false) 데이터만 가져옵니다.
        CommunityFreeBoardDto board = freeboardService.getBoardDetail(boardId, false);
        return ResponseEntity.ok(board);
    }

    /**
     * 🌟 자유게시판 게시글 수정 API
     */
    @PostMapping("/api/freeboard/update")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> updateFreeboardPost(
            @ModelAttribute CommunityFreeBoardDto dto, 
            HttpSession session) {
        
        Map<String, Object> response = new HashMap<>();
        MemberDto loginUser = (MemberDto) session.getAttribute("loginUser");
        
        if (loginUser == null) {
            response.put("status", "error");
            response.put("message", "로그인이 필요합니다.");
            return ResponseEntity.status(401).body(response);
        }

        try {
            boolean isUpdated = freeboardService.updateBoard(dto, loginUser.getMemberId());
            if(isUpdated) {
                response.put("status", "success");
                response.put("message", "게시글이 성공적으로 수정되었습니다!");
                return ResponseEntity.ok(response);
            } else {
                response.put("status", "error");
                response.put("message", "수정 권한이 없습니다.");
                return ResponseEntity.status(403).body(response);
            }
        } catch (Exception e) {
            log.error("자유게시판 글 수정 실패", e);
            response.put("status", "error");
            response.put("message", "서버 오류가 발생했습니다.");
            return ResponseEntity.status(500).body(response);
        }
    }
    
    @GetMapping("/api/feed/{postId}")
    @ResponseBody
    public ResponseEntity<?> getFeedDetailForEdit(@PathVariable("postId") Long postId) {
        try {
            CommunityFeedListDto feed = feedService.getFeedById(postId);
            if (feed == null) {
                return ResponseEntity.status(404).body(Map.of("message", "존재하지 않는 게시글입니다."));
            }
            return ResponseEntity.ok(feed);
        } catch (Exception e) {
            log.error("피드 조회 실패", e);
            return ResponseEntity.status(500).build();
        }
    }

    @PostMapping("/api/feed/update")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> updateFeedPost(
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
            feedService.updateFeed(requestDTO, loginUser.getMemberId());
            
            response.put("status", "success");
            response.put("message", "피드가 성공적으로 수정되었습니다! ✨");
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            log.error("피드 수정 실패", e);
            response.put("status", "error");
            response.put("message", "수정 중 서버 오류가 발생했습니다.");
            return ResponseEntity.status(500).body(response);
        }
    }
    
}