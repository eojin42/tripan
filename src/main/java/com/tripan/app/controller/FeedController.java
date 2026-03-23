package com.tripan.app.controller;

import java.util.List;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.tripan.app.domain.dto.TripDto;
import com.tripan.app.mapper.TripMapper;
import com.tripan.app.service.TripService;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/feed")
@RequiredArgsConstructor
public class FeedController {

    private final TripMapper tripMapper;
    private final TripService tripService;

    @GetMapping("/feed_list")
    public String feed_list(Model model) {
        return "feed/feed_list";
    }

    @GetMapping("/feed_detail")
    public String feed_detail(@RequestParam(name = "tripId") Long tripId, Model model) {
        TripDto trip = tripMapper.selectPublicTripDetail(tripId);
        if (trip == null) return "redirect:/feed/feed_list";
        model.addAttribute("trip", trip);
        return "feed/feed_detail";
    }

    /**
     * 공개 여행 전체 무한스크롤 API
     * GET /feed/public-trips?page=0&size=12
     */
    @GetMapping("/public-trips")
    @ResponseBody
    public ResponseEntity<List<TripDto>> getPublicTrips(
            @RequestParam(name = "page", defaultValue = "0")  int page,
            @RequestParam(name = "size", defaultValue = "12") int size) {
        int offset = page * size;
        List<TripDto> trips = tripMapper.selectPublicTripsPaged(offset, size + 1);
        return ResponseEntity.ok(trips);
    }

    /**
     * 피드 상세 API — 여행 정보 + Day/일정 + 태그 + 비슷한 여행
     * GET /feed/detail-data?tripId=21
     */
    @GetMapping("/detail-data")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getDetailData(
            @RequestParam(name = "tripId") Long tripId,
            HttpSession session) {

        TripDto trip = tripMapper.selectPublicTripDetail(tripId);
        if (trip == null) return ResponseEntity.notFound().build();

        // 일정 (Day + Item + Place + Image)
        TripDto fullDetail = tripService.getTripDetails(tripId);

        // 태그
        List<String> tags = tripMapper.selectTagsByTripId(tripId);

        // 비슷한 여행 (도시 첫 번째 키워드 추출)
        String cityKeyword = "";
        if (trip.getCitiesStr() != null && !trip.getCitiesStr().isBlank()) {
            cityKeyword = trip.getCitiesStr().split("[,\\s]+")[0].trim();
        }
        List<TripDto> related = tripMapper.selectRelatedPublicTrips(tripId, cityKeyword);

        // 좋아요 수
        int likeCount = tripMapper.selectTripLikeCount(tripId);

        // 내가 좋아요 했는지
        Long memberId = getLoginMemberId(session);
        boolean myLike = memberId != null && tripMapper.selectMyTripLike(tripId, memberId) > 0;

        return ResponseEntity.ok(Map.of(
            "trip",      trip,
            "days",      fullDetail != null && fullDetail.getDays() != null ? fullDetail.getDays() : List.of(),
            "tags",      tags,
            "related",   related,
            "likeCount", likeCount,
            "myLike",    myLike
        ));
    }

    /**
     * 좋아요 토글
     * POST /feed/like?tripId=21
     */
    @PostMapping("/like")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> toggleLike(
            @RequestParam(name = "tripId") Long tripId,
            HttpSession session) {
        Long memberId = getLoginMemberId(session);
        if (memberId == null) return ResponseEntity.status(401).body(Map.of("success", false));

        boolean isLiked = tripMapper.selectMyTripLike(tripId, memberId) > 0;
        if (isLiked) {
            tripMapper.deleteTripLike(tripId, memberId);
        } else {
            tripMapper.insertTripLike(tripId, memberId);
        }
        int newCount = tripMapper.selectTripLikeCount(tripId);
        return ResponseEntity.ok(Map.of("success", true, "liked", !isLiked, "count", newCount));
    }

    /**
     * 담아오기
     * POST /feed/scrap?tripId=21
     */
    @PostMapping("/scrap")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> scrapFeed(
            @RequestParam(name = "tripId") Long tripId,
            HttpSession session) {
        Long memberId = getLoginMemberId(session);
        if (memberId == null) return ResponseEntity.status(401).body(Map.of("success", false, "message", "로그인이 필요합니다"));
        try {
            Long newTripId = tripService.cloneTrip(tripId, memberId);
            return ResponseEntity.ok(Map.of("success", true, "newTripId", newTripId));
        } catch (Exception e) {
            return ResponseEntity.status(500).body(Map.of("success", false, "message", e.getMessage()));
        }
    }

    private Long getLoginMemberId(HttpSession session) {
        Object user = session.getAttribute("loginUser");
        if (user == null) return null;
        try { return (Long) user.getClass().getMethod("getMemberId").invoke(user); }
        catch (Exception e) { return null; }
    }
}