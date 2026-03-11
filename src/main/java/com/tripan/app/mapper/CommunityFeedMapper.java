package com.tripan.app.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.tripan.app.domain.dto.CommunityFeedCommentDto;
import com.tripan.app.domain.dto.CommunityFeedListDto;

import java.util.List;
import java.util.Map;

@Mapper
public interface CommunityFeedMapper {
    
    void insertFeedPost(Map<String, Object> paramMap);
    
    List<CommunityFeedListDto> getFeedList();
    List<CommunityFeedListDto> getFeedList(@Param("loginMemberId") Long loginMemberId);
    
    int checkFollow(@Param("followerId") Long followerId, @Param("followingId") Long followingId);
    void insertFollow(@Param("followerId") Long followerId, @Param("followingId") Long followingId);
    void deleteFollow(@Param("followerId") Long followerId, @Param("followingId") Long followingId);

    int checkFeedLike(Map<String, Object> params);
    
    void insertFeedLike(Map<String, Object> params);
    
    void deleteFeedLike(Map<String, Object> params);
    
    void updateFeedLikeCount(@Param("postId") Long postId, @Param("amount") int amount);
    
    int getFeedLikeCount(@Param("postId") Long postId);
    
    List<CommunityFeedCommentDto> getFeedComments(@Param("postId") Long postId);
    void insertFeedComment(CommunityFeedCommentDto dto);
    
}