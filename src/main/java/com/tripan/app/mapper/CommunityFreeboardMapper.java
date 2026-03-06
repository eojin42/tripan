package com.tripan.app.mapper;

import java.util.List;
import org.apache.ibatis.annotations.Mapper;

import com.tripan.app.domain.dto.CommunityFreeBoardDto;

@Mapper
public interface CommunityFreeboardMapper {
    List<CommunityFreeBoardDto> selectAll();

    List<CommunityFreeBoardDto> selectByCategory(String category);

    CommunityFreeBoardDto selectById(Long boardId);

    int insertBoard(CommunityFreeBoardDto board);

    void updateViewCount(Long boardId);
    
    void updateLikeCount(Long boardId);
    void updateReplyCount(Long boardId);
}