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
    
}