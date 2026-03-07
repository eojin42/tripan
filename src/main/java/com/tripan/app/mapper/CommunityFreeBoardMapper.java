package com.tripan.app.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.tripan.app.domain.dto.CommunityFreeBoardDto;
import com.tripan.app.domain.dto.CommunityFreeboardCommentDto;

@Mapper
public interface CommunityFreeBoardMapper {
    List<CommunityFreeBoardDto> selectAll();

    List<CommunityFreeBoardDto> selectByCategory(String category);

    CommunityFreeBoardDto selectById(Long boardId);

    int insertBoard(CommunityFreeBoardDto board);

    void updateViewCount(Long boardId);
    
    void updateReplyCount(Long boardId);
    
    List<CommunityFreeboardCommentDto> selectComments(Long boardId);
    
    void insertComment(CommunityFreeboardCommentDto dto);
    
    int getLikeCount(Long boardId);
    int checkLike(Map<String, Object> map); // 좋아요 여부 확인 (target_type 포함)
    void insertLike(Map<String, Object> map); // 좋아요 추가
    void deleteLike(Map<String, Object> map); // 좋아요 취소
    void updateLikeCount(@Param("boardId") Long boardId, @Param("amount") int amount);
    
}