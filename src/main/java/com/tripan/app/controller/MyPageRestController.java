package com.tripan.app.controller;

import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.tripan.app.domain.dto.MemberDto;
import com.tripan.app.service.MyPageService;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/mypage/api/*")
@RequiredArgsConstructor
public class MyPageRestController {
	private final MyPageService myPageService;
	
	@GetMapping("summary")
	public ResponseEntity<?> getSummary(HttpSession session){
		MemberDto loginUser = getLoginUser(session);
		if(loginUser == null) return unauthorized();
		return ResponseEntity.ok(myPageService.getMyPageSummary(loginUser.getMemberId()));
	}
	
	@GetMapping("trips")
	public ResponseEntity<?> getTrips(HttpSession session){
		MemberDto loginUser = getLoginUser(session);
		if(loginUser == null) return unauthorized();
		return ResponseEntity.ok(myPageService.getMyTrips(loginUser.getMemberId()));
	}
	
	@GetMapping("reviews")
	public ResponseEntity<?> getReviews(HttpSession session){
		MemberDto loginUser = getLoginUser(session);
		if(loginUser == null) return unauthorized();
		
		return ResponseEntity.ok(myPageService.getMyReviews(loginUser.getMemberId()));
	}
	
	@DeleteMapping("/reviews/{reviewId}")
	public ResponseEntity<?> deleteReview(@PathVariable Long reviewId, HttpSession session){
		MemberDto loginUser = getLoginUser(session);
		if(loginUser == null) return unauthorized();
		
		try {
			myPageService.deleteReview(loginUser.getMemberId(), reviewId);
			return ResponseEntity.ok(Map.of("message","삭제되었습니다."));
			
		} catch (IllegalArgumentException e) {
			return ResponseEntity.status(403).body(Map.of("message",e.getMessage()));
		}
	}
	
	@GetMapping("bookmarks")
	public ResponseEntity<?> getBookmarks(@RequestParam(name="type", required = false)String type, HttpSession session){
		MemberDto loginUser = getLoginUser(session);
		if(loginUser == null) return unauthorized();
		
		return ResponseEntity.ok(myPageService.getMyBookmarks(loginUser.getMemberId(),type));
	}
	
	@DeleteMapping("bookmarks/{bookmarkId}")
	public ResponseEntity<?> deleteBookmarks(@PathVariable(name="bookmarkId") Long bookmarkId, HttpSession session){
		MemberDto loginUser = getLoginUser(session);
		if(loginUser == null) return unauthorized();
		
		try {
			myPageService.deleteBookmark(loginUser.getMemberId(), bookmarkId);
			return ResponseEntity.ok(Map.of("message","찜이 해제되었습니다."));
		} catch (IllegalArgumentException e) {
			return ResponseEntity.status(403).body(Map.of("message",e.getMessage()));
		}
	}
	
	@GetMapping("badges")
	public ResponseEntity<?> getBadges(HttpSession session){
		MemberDto loginUser = getLoginUser(session);
        if (loginUser == null) return unauthorized();
        return ResponseEntity.ok(myPageService.getMyBadges(loginUser.getMemberId()));
	}
	
	@PostMapping("badges/{badgeId}/equip")
	public ResponseEntity<?> equipBadge(@PathVariable Long badgeId,
            HttpSession session) {
		  MemberDto loginUser = getLoginUser(session);
	       if (loginUser == null) return unauthorized();
	        
	       try {
	    	   myPageService.updateEquippedBadge(loginUser.getMemberId(), badgeId);
	    	   return ResponseEntity.ok(Map.of("message","배지가 장착되었습니다."));
	       } catch (IllegalArgumentException e) {
	    	   return ResponseEntity.status(400).body(Map.of("message",e.getMessage()));
	       }
	}
	
   @GetMapping("/following")
    public ResponseEntity<?> getFollowing(HttpSession session) {
        MemberDto loginUser = getLoginUser(session);
        if (loginUser == null) return unauthorized();
        return ResponseEntity.ok(myPageService.getFollowingList(loginUser.getMemberId()));
    }

    @GetMapping("/followers")
    public ResponseEntity<?> getFollowers(HttpSession session) {
        MemberDto loginUser = getLoginUser(session);
        if (loginUser == null) return unauthorized();
        return ResponseEntity.ok(myPageService.getFollowerList(loginUser.getMemberId()));
    }

    @DeleteMapping("/following/{followingId}")
    public ResponseEntity<?> unfollow(@PathVariable Long followingId,
                                      HttpSession session) {
        MemberDto loginUser = getLoginUser(session);
        if (loginUser == null) return unauthorized();
        myPageService.unfollow(loginUser.getMemberId(), followingId);
        return ResponseEntity.ok(Map.of("message", "언팔로우 되었습니다."));
    }
    
    

	private MemberDto getLoginUser(HttpSession session) {
		return (MemberDto) session.getAttribute("loginUser");
	}
	
	private ResponseEntity<?> unauthorized(){
		return ResponseEntity.status(401).body(Map.of("message","로그인이 필요합니다."));
	}
}
