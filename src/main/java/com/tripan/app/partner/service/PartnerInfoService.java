package com.tripan.app.partner.service;

import com.tripan.app.partner.domain.dto.PartnerInfoDto;

public interface PartnerInfoService {
    PartnerInfoDto getPartnerInfo(Long memberId);
    void updatePartnerInfo(PartnerInfoDto dto);
    
    Long getPlaceIdByMemberId(Long memberId);
}