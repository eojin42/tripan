package com.tripan.app.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.tripan.app.domain.dto.AccommodationDetailDto;
import com.tripan.app.domain.dto.AccommodationDto;
import com.tripan.app.domain.dto.AdSearchConditionDto;
import com.tripan.app.domain.dto.RoomDto;

@Mapper
public interface AccommodationMapper {
	public List<AccommodationDto> selectAccommodationList(AdSearchConditionDto condition);
	
	public AccommodationDetailDto selectAccommodationDetail(Long placeId);
    
    public List<String> selectAccommodationImages(Long placeId);
    
    public List<RoomDto> selectRoomsByPlaceId(Long placeId);
}
