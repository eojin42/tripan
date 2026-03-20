package com.tripan.app.partner.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import com.tripan.app.partner.domain.dto.PartnerFacilityUpdateDto;

@Mapper
public interface PartnerFacilityMapper {
    
    void updatePlaceIsActive(PartnerFacilityUpdateDto dto);
    
    String getAfIdByPlaceId(Long placeId);

    void updateAccommodationRules(PartnerFacilityUpdateDto dto);
    void updateAccommodationFacilities(@Param("dto") PartnerFacilityUpdateDto dto, @Param("afId") String afId);

    void insertAccommodationRules(@Param("dto") PartnerFacilityUpdateDto dto, @Param("afId") String afId);
    void insertAccommodationFacilities(@Param("dto") PartnerFacilityUpdateDto dto, @Param("afId") String afId);

    void deleteOtherFacilityByAfId(String afId);
    void insertOtherFacilityByAfId(@Param("afId") String afId, @Param("otherFacility") String otherFacility);
}