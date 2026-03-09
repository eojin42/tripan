package com.tripan.app.service;

import com.tripan.app.domain.dto.CommunityMateDto;
import com.tripan.app.domain.dto.CommunityMateCommentDto;
import com.tripan.app.mapper.CommunityMateMapper;
import com.tripan.app.mapper.CommunityMateCommentMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class CommunityMateServiceImpl implements CommunityMateService {

    private final CommunityMateMapper mateMapper;
    private final CommunityMateCommentMapper mateCommentMapper; 

    @Override
    public List<CommunityMateDto> getMateList(Long regionId, String startDate, String endDate, String searchTag) {
        return mateMapper.selectMateList(regionId, startDate, endDate, searchTag);
    }

    @Override
    @Transactional 
    public void registerMate(CommunityMateDto dto) {
        if(dto.getStatus() == null) {
            dto.setStatus("OPEN"); 
        }
        mateMapper.insertMate(dto);
    }

    @Override
    public CommunityMateDto getMateDetail(Long mateId) {
        return mateMapper.selectMateById(mateId);
    }

    @Override
    @Transactional
    public void registerMateComment(CommunityMateCommentDto dto) {
        mateCommentMapper.insertComment(dto);
    }

    @Override
    public Map<String, Object> getMateComments(Long mateId, int page) {
        int limit = 5; 
        int offset = (page - 1) * limit;
        
        List<CommunityMateCommentDto> comments = mateCommentMapper.selectComments(mateId, offset, limit);
        int totalCount = mateCommentMapper.countComments(mateId);
        int totalPages = (int) Math.ceil((double) totalCount / limit);
        
        List<CommunityMateCommentDto> childComments = mateCommentMapper.selectChildComments(mateId);
        
        Map<String, Object> response = new HashMap<>();
        response.put("comments", comments);
        response.put("totalCount", totalCount);
        response.put("totalPages", totalPages);
        response.put("currentPage", page);
        response.put("childComments", childComments);
        
        
        return response;
    }
    
    @Override
    @Transactional
    public boolean deleteMateComment(Long commentId, Long memberId) {
        Long ownerId = mateCommentMapper.selectCommentOwner(commentId);
        if (ownerId != null && ownerId.equals(memberId)) {
            mateCommentMapper.deleteCommentAndChildren(commentId);
            return true;
        }
        return false;
    }
    
    @Override
    @Transactional
    public boolean changeMateStatus(Long mateId, String status, Long memberId) {
        CommunityMateDto mate = mateMapper.selectMateById(mateId);
        if (mate != null && mate.getMemberId().equals(memberId)) {
            mateMapper.updateMateStatus(mateId, status);
            return true;
        }
        return false;
    }
}