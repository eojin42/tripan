package com.tripan.app.mapper;

import java.util.List;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import com.tripan.app.domain.dto.FestivalDto;
import com.tripan.app.domain.dto.FestivalImageDto;

@Mapper
public interface FestivalMapper {
    
    int insertFestival(FestivalDto festival);
    int insertFestivalImages(List<FestivalImageDto> imageList);

    
    /**
     * 특정 연/월에 진행되는 축제 목록 조회 (place 테이블과 JOIN)
     * @Param 어노테이션을 써야 XML에서 year, month 변수를 바로 쓸 수 있습니다.
     */
    List<FestivalDto> selectFestivalsByMonth(@Param("year") int year, @Param("month") int month);
    
    /**
     * 축제 상세 정보 조회 (축제 기본 정보 + 상세 내용)
     */
    FestivalDto selectFestivalDetail(Long festivalId);
    
    /**
     * 축제 상세 갤러리 이미지 조회
     */
    List<FestivalImageDto> selectFestivalImages(Long festivalId);
}