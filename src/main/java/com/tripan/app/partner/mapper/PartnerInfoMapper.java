package com.tripan.app.partner.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;

import com.tripan.app.partner.domain.dto.PartnerInfoDto;

@Mapper
public interface PartnerInfoMapper {

    PartnerInfoDto getPartnerInfoByMemberId(Long memberId);
    void updatePartnerInfo(PartnerInfoDto dto);
    Long getPlaceIdByMemberId(Long memberId);
    
    List<PartnerInfoDto> getPartnerListByMemberId(Long memberId); 
    
    Long getPlaceIdByPartnerId(Long partnerId);
    Map<String, Object> getFacilityByAfId(String afId);
    
    void updatePlaceInfo(PartnerInfoDto dto);
}