package com.tripan.app.service;

import java.util.List;
import java.util.Map;

import com.tripan.app.domain.dto.CommunityFreeBoardDto;
import com.tripan.app.domain.dto.CommunityFreeboardCommentDto;

public interface CommunityFreeboardService {
    // 게시글 전체 목록 조회
    List<CommunityFreeBoardDto> getBoardList();
    
    // 게시글 등록 (파일 업로드 처리는 컨트롤러나 서비스에서 추가 구현 가능)
    void registerBoard(CommunityFreeBoardDto dto);
    
    // 게시글 상세 조회 및 조회수 증가
    CommunityFreeBoardDto getBoardDetail(Long boardId, boolean updateView);
    
    List<CommunityFreeboardCommentDto> getCommentList(Long boardId);
    
    void registerComment(CommunityFreeboardCommentDto dto);
    int incrementLikeCount(Long boardId);
    Map<String, Object> toggleLike(Long boardId, Long memberId);
    
    int checkLikeStatus(Long boardId, Long memberId); // 좋아요 여부 확인
    
    
}