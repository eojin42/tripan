package com.tripan.app.partner.mapper;

import org.apache.ibatis.annotations.Mapper;
import com.tripan.app.partner.domain.dto.PartnerInfoDto;

@Mapper
public interface PartnerInfoMapper {

	PartnerInfoDto getPartnerInfoByMemberId(Long memberId);
    void updatePartnerInfo(PartnerInfoDto dto);
    Long getPlaceIdByMemberId(Long memberId);
}



