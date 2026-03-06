package com.tripan.app.service;

import java.util.List;

import com.tripan.app.domain.dto.CommunityFreeBoardDto;

public interface CommunityFreeboardService {
    // 게시글 전체 목록 조회
    List<CommunityFreeBoardDto> getBoardList();
    
    // 게시글 등록 (파일 업로드 처리는 컨트롤러나 서비스에서 추가 구현 가능)
    void registerBoard(CommunityFreeBoardDto dto);
    
    // 게시글 상세 조회 및 조회수 증가
    CommunityFreeBoardDto getBoardDetail(Long boardId);
    
    
}