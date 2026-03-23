package com.tripan.app.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.tripan.app.domain.dto.TripDto;
import com.tripan.app.mapper.TripMapper;

import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/feed")
@RequiredArgsConstructor
public class FeedController {

    private final TripMapper tripMapper;

    @GetMapping({"/feed_list"})
    public String feed_list(Model model) {
        return "feed/feed_list";
    }

    @GetMapping({"/feed_detail"})
    public String feed_detail(Model model) {
        return "feed/feed_detail";
    }

    /**
     * 공개 여행 전체 무한스크롤 API
     * GET /feed/public-trips?page=0&size=12
     *
     * 응답: JSON 배열 (TripDto 리스트)
     * hasMore: 다음 페이지 존재 여부 판단을 위해 size+1개 조회 후 클라이언트에서 처리
     */
    @GetMapping("/public-trips")
    @ResponseBody
    public ResponseEntity<List<TripDto>> getPublicTrips(
            @RequestParam(name = "page", defaultValue = "0")  int page,
            @RequestParam(name = "size", defaultValue = "12") int size) {

        int offset = page * size;
        // size+1개를 가져와서 클라이언트가 hasMore를 판단할 수 있도록 함
        List<TripDto> trips = tripMapper.selectPublicTripsPaged(offset, size + 1);
        return ResponseEntity.ok(trips);
    }
}