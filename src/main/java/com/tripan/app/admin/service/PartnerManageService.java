package com.tripan.app.admin.service;

import java.util.List;

import com.tripan.app.admin.domain.dto.PartnerKpiDto;
import com.tripan.app.admin.domain.dto.PartnerManageDto;

public interface PartnerManageService {

	List<PartnerManageDto> getAllPartners();
    List<PartnerManageDto> getActivePartners();
    PartnerKpiDto getKpi();
    void approvePartner(Long partnerId, Double commissionRate);
    void rejectPartner(Long partnerId, String rejectReason);
    void suspendPartner(Long partnerId);
    void registerPartner(PartnerManageDto req);

}
