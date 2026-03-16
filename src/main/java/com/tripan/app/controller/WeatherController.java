package com.tripan.app.controller;

import com.tripan.app.domain.dto.TripDto.WeatherResponseDto;
import com.tripan.app.service.WeatherService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * GET /api/weather?city=제주&startDate=2025-04-01&endDate=2025-04-10
 */
@RestController
@RequestMapping("/api/weather")
@RequiredArgsConstructor
public class WeatherController {

    private final WeatherService weatherService;

    @GetMapping
    public ResponseEntity<WeatherResponseDto> getWeather(
            @RequestParam("city") String city,
            @RequestParam(name = "startDate", required = false) String startDate,
            @RequestParam(name = "endDate",   required = false) String endDate) {

        return ResponseEntity.ok(weatherService.getWeather(city, startDate, endDate));
    }
}
