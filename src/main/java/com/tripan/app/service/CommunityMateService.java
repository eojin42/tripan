package com.tripan.app.service;

import com.tripan.app.domain.dto.CommunityMateCommentDto;
import com.tripan.app.domain.dto.CommunityMateDto;
import java.util.List;
import java.util.Map;

public interface CommunityMateService {
    
    List<CommunityMateDto> getMateList(Long regionId, String startDate, String endDate, String searchTag);
    void registerMate(CommunityMateDto dto);
    void registerMateComment(CommunityMateCommentDto dto);
    Map<String, Object> getMateComments(Long mateId, int page);
    boolean deleteMateComment(Long commentId, Long memberId);
    boolean changeMateStatus(Long mateId, String status, Long memberId);
    
    List<CommunityMateDto> getUserMateList(Long memberId);
    
    CommunityMateDto getMateDetail(Long mateId, boolean updateView);
    
    void updateMateStatus(Long mateId, String status);
    void deleteMatePost(Long mateId, Long memberId);
    
    List<CommunityMateCommentDto> getMateComments(Long mateId);
    void addMateComment(CommunityMateCommentDto commentDto);
    
}