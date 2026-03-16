package com.tripan.app.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.tripan.app.domain.dto.TripDto.ItineraryItemDto;

@Mapper
public interface ItineraryMapper {

    // 일정(Itinerary Item) 관련 메서드
    /**
     * 특정 일자(Day)에 속한 모든 일정 항목과, 각 항목에 달린 이미지 목록을 한 번에 조회
     * @param dayId 일자 식별자 (FK)
     * @return 이미지 리스트를 품고 있는 일정 항목 DTO 리스트
     */
    List<ItineraryItemDto> selectItemsWithImagesByDayId(@Param("dayId") Long dayId);


    // 일정 이미지(Itinerary Image) 관련 메서드
    /** 특정 일정 아이템의 이미지 URL 목록 조회 */
    List<String> findImageUrlsByItemId(@Param("itemId") Long itemId);

    // 이미지 삽입 
    void insertImage(@Param("itemId") Long itemId, @Param("imageUrl") String imageUrl);

    void deleteImagesByItemIdAndUrls(@Param("itemId") Long itemId, @Param("urls") List<String> urls);

    // 특정 아이템의 이미지 전체 삭제 
    void deleteAllImagesByItemId(@Param("itemId") Long itemId);

}