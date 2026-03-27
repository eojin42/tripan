package com.tripan.app.admin.service;

import java.util.Date;
import java.util.List;
import java.util.Map;

import com.tripan.app.admin.domain.dto.PartnerKpiDto;
import com.tripan.app.admin.domain.dto.PartnerManageDto;

public interface PartnerManageService {

    List<PartnerManageDto> getAllPartners();
    List<PartnerManageDto> getActivePartners();
    PartnerKpiDto getKpi();
    PartnerManageDto getPartnerDetail(Long partnerId);
    void approvePartner(Long partnerId, Double commissionRate, Date contractEndDate);
    void rejectPartner(Long partnerId, String rejectReason);
    void suspendPartner(Long partnerId);
    void registerPartner(PartnerManageDto req);
    void expireContracts();
    List<Map<String, Object>> getPartnerDocs(Long partnerId);
    List<Map<String, Object>> getPlacesByPartnerId(Long partnerId);
    List<Map<String, Object>> getReservationsByPartnerId(Long partnerId);
}