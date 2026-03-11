package com.tripan.app.service;

import com.tripan.app.domain.dto.TripDto;
import com.tripan.app.mapper.TripMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class MyTripsServiceImpl implements MyTripsService {

    private final TripMapper tripMapper;

    @Override
    public List<TripDto> getMyTrips(Long memberId) {
        List<TripDto> trips = tripMapper.selectMyTrips(memberId);
        // cities: "서울, 제주" (String) → List<String> 변환
        trips.forEach(dto -> {
            if (dto.getCitiesStr() != null && !dto.getCitiesStr().isBlank()) {
                java.util.List<String> cityList = java.util.Arrays.stream(dto.getCitiesStr().split(","))
                    .map(String::trim)
                    .filter(s -> !s.isEmpty())
                    .collect(java.util.stream.Collectors.toList());
                dto.setCities(cityList);
            }
        });
        return trips;
    }
}
