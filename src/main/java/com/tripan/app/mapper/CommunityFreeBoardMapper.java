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
    int checkLike(Map<String, Object> map);
    void insertLike(Map<String, Object> map); 
    void deleteLike(Map<String, Object> map);
    void updateLikeCount(@Param("boardId") Long boardId, @Param("amount") int amount);
    
    Long getBoardWriterId(Long boardId);
    int deleteBoard(Long boardId);
    int deleteComment(Long commentId);
    
    CommunityFreeboardCommentDto selectCommentById(Long commentId);
    void decreaseReplyCount(Long boardId);
    
    int updateBoard(CommunityFreeBoardDto dto);
    List<CommunityFreeBoardDto> getUserBoardList(Long memberId);
    
    void updateStatus(@Param("boardId") Long boardId, @Param("status") int status);
    void updateCommentStatus(@Param("commentId") Long commentId, @Param("status") int status);
}
    
