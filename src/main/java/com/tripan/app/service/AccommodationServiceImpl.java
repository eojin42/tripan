package com.tripan.app.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.tripan.app.domain.dto.AccommodationDetailDto;
import com.tripan.app.domain.dto.AccommodationDto;
import com.tripan.app.domain.dto.AdSearchConditionDto;
import com.tripan.app.mapper.AccommodationMapper;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class AccommodationServiceImpl implements AccommodationService{
	private final AccommodationMapper mapper;
	
	
	@Override
	public List<AccommodationDto> searchAccommodations(AdSearchConditionDto condition) {
			return mapper.selectAccommodationList(condition);

	}


	@Override
	public AccommodationDetailDto getAccommodationDetail(Long placeId) {
		
		AccommodationDetailDto detail = mapper.selectAccommodationDetail(placeId);
        
        if (detail != null) {
            detail.setImages(mapper.selectAccommodationImages(placeId));
            
            detail.setRooms(mapper.selectRoomsByPlaceId(placeId));
        }
        
        return detail;
	}
	
	
}
