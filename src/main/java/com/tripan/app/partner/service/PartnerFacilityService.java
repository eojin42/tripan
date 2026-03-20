package com.tripan.app.partner.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.tripan.app.partner.domain.dto.PartnerFacilityUpdateDto;
import com.tripan.app.partner.mapper.PartnerFacilityMapper;

@Service
public class PartnerFacilityService {

    @Autowired
    private PartnerFacilityMapper facilityMapper;

    @Transactional(rollbackFor = Exception.class)
    public void updateFacility(PartnerFacilityUpdateDto dto) throws Exception {
        
        facilityMapper.updatePlaceIsActive(dto);

        String afId = facilityMapper.getAfIdByPlaceId(dto.getPlaceId());

        if (afId == null || afId.isEmpty()) {
        	
            afId = "AF" + dto.getPlaceId(); 
            
            facilityMapper.insertAccommodationFacilities(dto, afId);
            facilityMapper.insertAccommodationRules(dto, afId);
        } 
        else {
            facilityMapper.updateAccommodationRules(dto);
            facilityMapper.updateAccommodationFacilities(dto, afId);
        }

        facilityMapper.deleteOtherFacilityByAfId(afId);
        
        if (dto.getOtherFacility() != null && !dto.getOtherFacility().trim().isEmpty()) {
            facilityMapper.insertOtherFacilityByAfId(afId, dto.getOtherFacility().trim());
        }
    }
}