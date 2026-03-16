package com.tripan.app.service;

import com.tripan.app.domain.dto.TripDto.WeatherResponseDto;

public interface WeatherService {
    WeatherResponseDto getWeather(String city, String startDate, String endDate);
}
