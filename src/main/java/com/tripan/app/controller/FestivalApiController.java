package com.tripan.app.controller;

import com.tripan.app.domain.dto.FestivalDto;
import com.tripan.app.service.FestivalService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/festivals") // 기본 URL 주소 설정
@RequiredArgsConstructor 
public class FestivalApiController {

    private final FestivalService festivalService;

    /**
     * 프론트엔드 달력에서 넘어온 연도와 월을 받아 축제 데이터를 반환합니다.
     * 호출 주소 예시: GET /api/festivals?year=2026&month=3
     */
    @GetMapping
    public ResponseEntity<List<FestivalDto>> getFestivals(
            @RequestParam("year") int year,
            @RequestParam("month") int month) {
        
        List<FestivalDto> festivalList = festivalService.getFestivals(year, month);
        return ResponseEntity.ok(festivalList);
    }
}