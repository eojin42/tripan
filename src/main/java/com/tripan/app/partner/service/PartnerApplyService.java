package com.tripan.app.partner.service;

import com.tripan.app.partner.domain.dto.PartnerApplyDto;

public interface PartnerApplyService {
    
    void applyPartner(PartnerApplyDto dto) throws Exception;
    
}