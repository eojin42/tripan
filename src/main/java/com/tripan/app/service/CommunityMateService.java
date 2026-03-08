package com.tripan.app.service;

import com.tripan.app.domain.dto.CommunityMateDto;
import java.util.List;

public interface CommunityMateService {
    
    List<CommunityMateDto> getMateList(Long regionId, String startDate, String endDate, String searchTag);
    void registerMate(CommunityMateDto dto);
    CommunityMateDto getMateDetail(Long mateId);
}