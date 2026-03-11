package com.tripan.app.service;

import com.tripan.app.domain.dto.TripDto;

import java.util.List;

public interface MyTripsService {

    /**
     * 로그인 멤버가 방장이거나 동행자로 참여 중인 여행 목록 조회
     */
    List<TripDto> getMyTrips(Long memberId);
}
