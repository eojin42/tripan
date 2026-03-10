package com.tripan.app.mapper;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.tripan.app.domain.dto.CommunityFeedListDto;

import java.util.List;
import java.util.Map;

@Mapper
public interface CommunityFeedMapper {
    void insertFeedPost(Map<String, Object> paramMap);
    List<CommunityFeedListDto> getFeedList();
    
    int checkFollow(@Param("followerId") Long followerId, @Param("followingId") Long followingId);
    void insertFollow(@Param("followerId") Long followerId, @Param("followingId") Long followingId);
    void deleteFollow(@Param("followerId") Long followerId, @Param("followingId") Long followingId);

    List<CommunityFeedListDto> getFeedList(@Param("loginMemberId") Long loginMemberId);
}