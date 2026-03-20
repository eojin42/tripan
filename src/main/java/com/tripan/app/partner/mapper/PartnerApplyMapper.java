package com.tripan.app.partner.mapper;

import java.util.Map;
import org.apache.ibatis.annotations.Mapper;
import com.tripan.app.partner.domain.dto.PartnerApplyDto;
import com.tripan.app.partner.domain.dto.PartnerFileDto;

@Mapper
public interface PartnerApplyMapper {
    
    void insertPartner(PartnerApplyDto dto);
    void insertPartnerStatus(Long partnerId);
    void insertPartnerFile(PartnerFileDto fileDto);
    
    String findPartnerStatusByMemberId(Long memberId);
    PartnerApplyDto findPartnerApplyByMemberId(Long memberId);
    
    void insertEmptyPlace(PartnerApplyDto dto);
    void insertEmptyAccommodation(Map<String, Object> params);
}