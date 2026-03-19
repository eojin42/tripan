package com.tripan.app.partner.service;

import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.tripan.app.partner.domain.dto.PartnerInfoDto;
import com.tripan.app.partner.mapper.PartnerInfoMapper;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class PartnerInfoServiceImpl implements PartnerInfoService {

    private final PartnerInfoMapper partnerInfoMapper;

    @Override
    public PartnerInfoDto getPartnerInfo(Long memberId) {
        return partnerInfoMapper.getPartnerInfoByMemberId(memberId);
    }

    @Override
    @Transactional
    public void updatePartnerInfo(PartnerInfoDto dto) {
        partnerInfoMapper.updatePartnerInfo(dto);
    }

    @Override
    public Long getPlaceIdByMemberId(Long memberId) {
        return partnerInfoMapper.getPlaceIdByMemberId(memberId);
    }
    
    @Override
    public List<PartnerInfoDto> getPartnerListByMemberId(Long memberId) {
        return partnerInfoMapper.getPartnerListByMemberId(memberId);
    }
    
    @Override
    public Long getPlaceIdByPartnerId(Long partnerId) {
        return partnerInfoMapper.getPlaceIdByPartnerId(partnerId);
    }

    @Override
    public Map<String, Object> getFacilityByAfId(String afId) {
        return partnerInfoMapper.getFacilityByAfId(afId);
    }
    
}