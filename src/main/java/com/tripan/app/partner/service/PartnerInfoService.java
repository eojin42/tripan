package com.tripan.app.partner.service;

import java.util.List;
import java.util.Map;

import com.tripan.app.partner.domain.dto.PartnerInfoDto;

public interface PartnerInfoService {
    PartnerInfoDto getPartnerInfo(Long memberId);
    void updatePartnerInfo(PartnerInfoDto dto);
    
    Long getPlaceIdByMemberId(Long memberId);
    
    List<PartnerInfoDto> getPartnerListByMemberId(Long memberId);
    
    Long getPlaceIdByPartnerId(Long partnerId);
    Map<String, Object> getFacilityByAfId(String afId);
}