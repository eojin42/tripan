package com.tripan.app.controller;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.util.List;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.tripan.app.domain.dto.ConquestMapDto;
import com.tripan.app.domain.dto.MemberCouponDto;
import com.tripan.app.domain.dto.MemberDto;
import com.tripan.app.domain.dto.PointSummaryDto;
import com.tripan.app.domain.dto.SessionInfo;
import com.tripan.app.domain.dto.TripDto;
import com.tripan.app.security.LoginMemberUtil;
import com.tripan.app.service.MemberCouponService;
import com.tripan.app.service.MyPageService;
import com.tripan.app.service.MyTripsService;
import com.tripan.app.service.PointService;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RestController
@RequestMapping("/mypage/api/**")
@RequiredArgsConstructor
@Slf4j
public class MyPageRestController {
	private final MyPageService myPageService;
	private final MyTripsService myTripService;
	private final MemberCouponService memberCouponService;
	private final PointService pointService;
	
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
		return ResponseEntity.ok(myTripService.getMyTrips(loginUser.getMemberId()));
	}
	
	@GetMapping("reviews")
	public ResponseEntity<?> getReviews(HttpSession session){
		MemberDto loginUser = getLoginUser(session);
		if(loginUser == null) return unauthorized();
		
		return ResponseEntity.ok(myPageService.getMyReviews(loginUser.getMemberId()));
	}
	
	@DeleteMapping("/reviews/{reviewId}")
	public ResponseEntity<?> deleteReview(@PathVariable("reviewId") Long reviewId, HttpSession session){
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
	public ResponseEntity<?> equipBadge(@PathVariable("badgeId") Long badgeId, HttpSession session) {
		  MemberDto loginUser = getLoginUser(session);
	       if (loginUser == null) return unauthorized();
	        
	       try {
	    	   myPageService.updateEquippedBadge(loginUser.getMemberId(), badgeId);
	    	   return ResponseEntity.ok(Map.of("message","배지가 장착되었습니다."));
	       } catch (IllegalArgumentException e) {
	    	   return ResponseEntity.status(400).body(Map.of("message",e.getMessage()));
	       }
	}
	
	// 내 지도 데이터 불러오기
    @GetMapping("visited-regions-data")
    public ResponseEntity<?> getVisitedRegionsData(HttpSession session) {
        MemberDto loginUser = getLoginUser(session);
        if (loginUser == null) return unauthorized();
        
        List<ConquestMapDto> list = myPageService.getVisitedRegionsData(loginUser.getMemberId());
        return ResponseEntity.ok(list);
    }
	
    // 지도 색칠 기록 저장/수정 (map.jsp에서 FormData로 보냄)
    @PostMapping("visited-regions-save")
    public ResponseEntity<?> saveVisitedRegion(
            @ModelAttribute ConquestMapDto dto,
            @RequestParam(value = "photos", required = false) List<MultipartFile> photos,
            HttpSession session) {
     
        MemberDto loginUser = getLoginUser(session);
        if (loginUser == null) return unauthorized();
     
        try {
            dto.setMemberId(loginUser.getMemberId());
            myPageService.saveVisitedRegion(dto);  // insert or update
     
            // 사진 처리 (있을 때만)
            if (photos != null && !photos.isEmpty()) {
                String uploadDir = System.getProperty("user.home") + "/tripan/uploads/map_photos/";
                File dir = new File(uploadDir);
                if (!dir.exists()) dir.mkdirs();
     
                for (MultipartFile photo : photos) {
                    if (photo.isEmpty()) continue;
     
                    String ext      = StringUtils.getFilenameExtension(photo.getOriginalFilename());
                    String fileName = loginUser.getUsername() + "_" + System.currentTimeMillis() + "." + ext;
                    Files.copy(photo.getInputStream(), 
                            Path.of(uploadDir + fileName), 
                            StandardCopyOption.REPLACE_EXISTING);
     
                    // DB에 사진 경로 저장
                    myPageService.savePhoto(
                        loginUser.getMemberId(),
                        dto.getConquestMapId(),  // insertRegionData 후 selectKey로 세팅됨
                        "/uploads/map_photos/" + fileName
                    );
                }
            }
     
            return ResponseEntity.ok(Map.of("message", "저장되었습니다."));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(400).body(Map.of("message", e.getMessage()));
        } catch (Exception e) {
            log.error("saveVisitedRegion error", e);
            return ResponseEntity.status(500).body(Map.of("message", "서버 오류가 발생했습니다."));
        }
    }
	
 // 기록 삭제 (map.jsp에서 JSON 바디로 보냄)
    @DeleteMapping("visited-regions-delete")
    public ResponseEntity<?> deleteVisitedRegion(@RequestBody Map<String, String> body, HttpSession session) {
            
        MemberDto loginUser = getLoginUser(session);
        if (loginUser == null) return unauthorized();
        
        try {
            String sigunguName = body.get("sigunguName");
            myPageService.deleteVisitedRegion(loginUser.getMemberId(), sigunguName);
            return ResponseEntity.ok(Map.of("message", "기록이 삭제되었습니다."));
        } catch (Exception e) {
            return ResponseEntity.status(500).body(Map.of("message", "서버 오류가 발생했습니다."));
        }
    }
    
 // ── 사진 단건 삭제 ──
    @DeleteMapping("visited-regions-photo/{photoId}")
    public ResponseEntity<?> deletePhoto(@PathVariable("photoId") Long photoId,
            HttpSession session) {
     
        MemberDto loginUser = getLoginUser(session);
        if (loginUser == null) return unauthorized();
     
        try {
            myPageService.deletePhoto(loginUser.getMemberId(), photoId);
            return ResponseEntity.ok(Map.of("message", "사진이 삭제되었습니다."));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(403).body(Map.of("message", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(500).body(Map.of("message", "서버 오류가 발생했습니다."));
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
    public ResponseEntity<?> unfollow(@PathVariable("followingId") Long followingId,
                                      HttpSession session) {
        MemberDto loginUser = getLoginUser(session);
        if (loginUser == null) return unauthorized();
        myPageService.unfollow(loginUser.getMemberId(), followingId);
        return ResponseEntity.ok(Map.of("message", "언팔로우 되었습니다."));
    }
    
    @GetMapping("bookings")
    public ResponseEntity<?> getBookings(HttpSession session) {
        MemberDto loginUser = getLoginUser(session);
        if (loginUser == null) return unauthorized();
        return ResponseEntity.ok(myPageService.getMyBookings(loginUser.getMemberId()));
    }
    
    @GetMapping("upcoming")
    public ResponseEntity<?> getUpcoming(HttpSession session) {
        MemberDto loginUser = getLoginUser(session);
        if (loginUser == null) return unauthorized();
        
        List<TripDto> trips = myTripService.getMyTrips(loginUser.getMemberId());
        if (trips == null || trips.isEmpty()) return ResponseEntity.ok(Map.of());
        
        TripDto upcoming = trips.stream()
            .filter(t -> "PLANNING".equals(t.getStatus()) || "ONGOING".equals(t.getStatus()))
            .findFirst().orElse(null);
        
        return ResponseEntity.ok(upcoming != null ? upcoming : Map.of());
    }
    
    @GetMapping("coupons")
    public ResponseEntity<?> getMyCoupons(HttpSession session, @RequestParam("status") String status) {
        MemberDto loginUser = getLoginUser(session);
        if (loginUser == null) return unauthorized();
        
        try {
        	String dbStatus = status.equalsIgnoreCase("available") ? "AVAILABLE" : "USED";
            
            List<MemberCouponDto> coupons = memberCouponService.getMyCouponList(loginUser.getMemberId(), dbStatus);
            return ResponseEntity.ok(coupons);
        } catch (Exception e) {
            log.error("쿠폰 목록 로드 실패", e);
            return ResponseEntity.status(500).body(Map.of("message", "쿠폰 정보를 불러오는 중 오류가 발생했습니다."));
        }
    }
    
    /** 포인트 데이터 API (JSP에서 fetch로 호출) */
    @GetMapping("point/list")
    @ResponseBody
    public ResponseEntity<?> pointList() {
        SessionInfo info = LoginMemberUtil.getsessionInfo();
        if (info == null) {
            return ResponseEntity.status(401).body("로그인이 필요합니다.");
        }
 
        try {
            PointSummaryDto summary = pointService.getPointSummary(info.getMemberId());
            return ResponseEntity.ok(summary);
        } catch (Exception e) {
            log.error("포인트 내역 조회 오류 - memberId: {}", info.getMemberId(), e);
            return ResponseEntity.status(500).body("데이터 조회 중 오류가 발생했습니다.");
        }
    }
    
    private MemberDto getLoginUser(HttpSession session) {
		return (MemberDto) session.getAttribute("loginUser");
	}
	
	private ResponseEntity<?> unauthorized(){
		return ResponseEntity.status(401).body(Map.of("message","로그인이 필요합니다."));
	}
}
