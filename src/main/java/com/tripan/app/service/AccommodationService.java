package com.tripan.app.service;

import java.util.List;

import com.tripan.app.domain.dto.AccommodationDetailDto;
import com.tripan.app.domain.dto.AccommodationDto;
import com.tripan.app.domain.dto.AdSearchConditionDto;

public interface AccommodationService {
	public List<AccommodationDto> searchAccommodations(AdSearchConditionDto condition);
	
	public AccommodationDetailDto getAccommodationDetail(Long placeId);
}
