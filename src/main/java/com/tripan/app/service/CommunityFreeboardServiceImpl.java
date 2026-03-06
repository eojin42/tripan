package com.tripan.app.service;

import java.util.List;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.tripan.app.domain.dto.CommunityFreeBoardDto;
import com.tripan.app.mapper.CommunityFreeboardMapper;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class CommunityFreeboardServiceImpl implements CommunityFreeboardService {

    private final CommunityFreeboardMapper freeboardMapper;

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
        return freeboardMapper.selectById(boardId);
    }
}