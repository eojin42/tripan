package com.tripan.app.service;

import java.util.List;
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
    public CommunityFreeBoardDto getBoardDetail(Long boardId) {
        freeboardMapper.updateViewCount(boardId); // 조회수 증가
        return freeboardMapper.selectById(boardId); // 게시글 상세정보 
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
}