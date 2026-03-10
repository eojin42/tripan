package com.tripan.app.service;

import java.util.List;
import java.util.Map;

import com.tripan.app.domain.dto.CommunityFreeBoardDto;
import com.tripan.app.domain.dto.CommunityFreeboardCommentDto;

public interface CommunityFreeboardService {
    List<CommunityFreeBoardDto> getBoardList();
    
    void registerBoard(CommunityFreeBoardDto dto);
    
    CommunityFreeBoardDto getBoardDetail(Long boardId, boolean updateView);
    
    List<CommunityFreeboardCommentDto> getCommentList(Long boardId);
    
    void registerComment(CommunityFreeboardCommentDto dto);
    int incrementLikeCount(Long boardId);
    Map<String, Object> toggleLike(Long boardId, Long memberId);
    
    int checkLikeStatus(Long boardId, Long memberId); 
    
    
}