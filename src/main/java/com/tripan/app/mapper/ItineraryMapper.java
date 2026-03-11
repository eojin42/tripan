package com.tripan.app.mapper;


import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.tripan.app.domain.dto.TripDto.ItineraryItemDto;


@Mapper
public interface ItineraryMapper {

    /**
     * 특정 일자(Day)에 속한 모든 일정 항목과, 각 항목에 달린 이미지 목록을 한 번에 조회
     * * @param dayId 일자 식별자 (FK)
     * @return 이미지 리스트를 품고 있는 일정 항목 DTO 리스트
     */
    List<ItineraryItemDto> selectItemsWithImagesByDayId(@Param("dayId") Long dayId);

}