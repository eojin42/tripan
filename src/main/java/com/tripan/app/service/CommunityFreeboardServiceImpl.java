package com.tripan.app.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.tripan.app.domain.dto.CommunityFreeBoardDto;
import com.tripan.app.domain.dto.CommunityFreeboardCommentDto;
import com.tripan.app.mapper.CommunityFreeBoardMapper;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class CommunityFreeboardServiceImpl implements CommunityFreeboardService {

    private final CommunityFreeBoardMapper freeboardMapper;

    @Override
    public List<CommunityFreeBoardDto> getBoardList() {
        return freeboardMapper.selectAll();
    }

    @Override
    @Transactional
    public void registerBoard(CommunityFreeBoardDto dto) {
        freeboardMapper.insertBoard(dto);
    }

    @Override
    @Transactional
    public CommunityFreeBoardDto getBoardDetail(Long boardId, boolean updateView) {
    	if (updateView) {
            freeboardMapper.updateViewCount(boardId);
        }
        return freeboardMapper.selectById(boardId); 
    }
    
    @Override
    public List<CommunityFreeboardCommentDto> getCommentList(Long boardId) {
        return freeboardMapper.selectComments(boardId);
    }
    
    @Override
    @Transactional 
    public void registerComment(CommunityFreeboardCommentDto dto) {
        freeboardMapper.insertComment(dto);
        freeboardMapper.updateReplyCount(dto.getBoardId());
    }
    
    @Override
    @Transactional
    public int incrementLikeCount(Long boardId) {
    	freeboardMapper.updateLikeCount(boardId, 1);
        return freeboardMapper.getLikeCount(boardId);
    }
    
    @Override
    @Transactional
    public Map<String, Object> toggleLike(Long boardId, Long memberId) {
        Map<String, Object> params = new java.util.HashMap<>();
        params.put("boardId", boardId);
        params.put("memberId", memberId);
        
        int isLiked = freeboardMapper.checkLike(params);
        String status;
        int amount;
        
        if (isLiked > 0) {
            freeboardMapper.deleteLike(params); // 취소
            amount = -1;
            status = "unliked";
        } else { 
            freeboardMapper.insertLike(params); // 추가
            amount = 1;
            status = "liked";
        }
        
        freeboardMapper.updateLikeCount(boardId, amount);
        int newCount = freeboardMapper.getLikeCount(boardId);
        
        return Map.of("status", status, "count", newCount);
    }
    
    @Override
    public int checkLikeStatus(Long boardId, Long memberId) {
        Map<String, Object> params = new HashMap<>();
        params.put("boardId", boardId);
        params.put("memberId", memberId);
        return freeboardMapper.checkLike(params); 
    }
    
}