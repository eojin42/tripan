package com.tripan.app.service;

import com.tripan.app.domain.dto.FestivalDto;
import java.util.List;

public interface FestivalService {
    
    /**
     * 특정 연도와 월의 축제 목록을 공공데이터 포털에서 조회합니다.
     * * @param 	year  조회할 연도 
     *   @param 	month 조회할 월 
     *   @return    축제 정보 리스트
     */
    List<FestivalDto> getFestivals(int year, int month);
    
    
    /**
     * 여행 기간(startDate ~ endDate)과 겹치는 축제 목록 조회.
     * 각 축제의 상세 이미지 목록도 함께 포함됩니다.
     *
     * @param tripStart 여행 시작일 (YYYY-MM-DD)
     * @param tripEnd   여행 종료일 (YYYY-MM-DD)
     * @return 겹치는 축제 DTO 목록 (imageList 포함)
     */
    List<FestivalDto> getFestivalsByTripPeriod(String tripStart, String tripEnd);
    
}