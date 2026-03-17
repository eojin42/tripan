package com.tripan.app.admin.service;

import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.tripan.app.admin.mapper.PartnerManageMapper;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class PartnerManageServiceImpl implements PartnerManageService{
	 private final PartnerManageMapper partnerMapper;
	
	@Override
    public List<Map<String, Object>> getAllPartners() {
        return partnerMapper.selectAllPartners();
    }

	@Override
	public List<Map<String, Object>> getActivePartners() {
		return partnerMapper.selectActivePartners();
	}

	@Override
	@Transactional
	public void approvePartner(Long partnerId, Double commissionRate) {
		Map<String, Object> params = Map.of(
	            "partnerId",      partnerId,
	            "commissionRate", commissionRate,
	            "status",         "ACTIVE"
	        );
	        int affected = partnerMapper.updatePartnerStatus(params);
	        if (affected == 0) {
	            throw new IllegalArgumentException("파트너를 찾을 수 없습니다. ID: " + partnerId);
	        }
	        log.info("파트너 승인 완료 - ID: {}, 수수료율: {}%", partnerId, commissionRate);
	    }

	@Override
	@Transactional
	public void rejectPartner(Long partnerId, String rejectReason) {
		Map<String, Object> params = Map.of(
	            "partnerId",    partnerId,
	            "rejectReason", rejectReason,
	            "status",       "REJECTED"
	        );
	        int affected = partnerMapper.updatePartnerStatus(params);
	        if (affected == 0) {
	            throw new IllegalArgumentException("파트너를 찾을 수 없습니다. ID: " + partnerId);
	        }
	        log.info("파트너 반려 완료 - ID: {}, 사유: {}", partnerId, rejectReason);
	    }

	@Override
	@Transactional
	public void suspendPartner(Long partnerId) {
		Map<String, Object> params = Map.of(
	            "partnerId", partnerId,
	            "status",    "SUSPENDED"
	        );
	        int affected = partnerMapper.updatePartnerStatus(params);
	        if (affected == 0) {
	            throw new IllegalArgumentException("파트너를 찾을 수 없습니다. ID: " + partnerId);
	        }
	        log.info("파트너 차단 완료 - ID: {}", partnerId);
	    }
}
