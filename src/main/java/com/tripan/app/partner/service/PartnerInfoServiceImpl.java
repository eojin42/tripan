package com.tripan.app.partner.service;

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
}