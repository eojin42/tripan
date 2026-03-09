package com.tripan.app.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.tripan.app.domain.dto.CommunityMateCommentDto;

import java.util.List;

@Mapper
public interface CommunityMateCommentMapper {
    void insertComment(CommunityMateCommentDto dto);
    
    List<CommunityMateCommentDto> selectComments(
        @Param("mateId") Long mateId, 
        @Param("offset") int offset, 
        @Param("limit") int limit
    );
    
    int countComments(@Param("mateId") Long mateId);
    List<CommunityMateCommentDto> selectChildComments(@Param("mateId") Long mateId);
    
    Long selectCommentOwner(@Param("commentId") Long commentId);
    void deleteCommentAndChildren(@Param("commentId") Long commentId);
}
