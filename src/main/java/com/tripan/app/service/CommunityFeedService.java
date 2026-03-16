package com.tripan.app.service;

import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;

import com.tripan.app.domain.dto.CommunityFeedCommentDto;
import com.tripan.app.domain.dto.CommunityFeedListDto;
import com.tripan.app.domain.dto.CommunityFeedWriteRequestDto;
import com.tripan.app.domain.dto.CommunityUserActivityDto;
import com.tripan.app.domain.dto.MemberDto;

public interface CommunityFeedService {
	
	void insertFeed(CommunityFeedWriteRequestDto dto, Long memberId) throws Exception;
	public String toggleFollow(Long followerId, Long followingId);
	List<CommunityFeedListDto> getFeedList(Long loginMemberId);
	Map<String, Object> toggleFeedLike(Long postId, Long memberId);
	
    List<CommunityFeedCommentDto> getFeedComments(Long postId);
    void insertFeedComment(CommunityFeedCommentDto dto) throws Exception;
    
    boolean deleteFeedComment(Long commentId, Long memberId);
    boolean deleteFeed(Long postId, Long memberId);
    
    int getMyFeedCount(Long memberId);
    
    CommunityFeedListDto getFeedById(Long postId);
	void updateFeed(CommunityFeedWriteRequestDto dto, Long memberId) throws Exception;
	
	MemberDto getMemberInfo(Long memberId);
	List<CommunityFeedListDto> getUserFeedList(Long targetMemberId, Long loginMemberId);
	
	List<CommunityUserActivityDto> getUserActivityList(Long memberId);

	CommunityFeedListDto getFeedDetailFull(Long postId, Long loginMemberId);
	
	List<Map<String, Object>> getFollowList(String type, Long targetMemberId, Long currentUserId);
	
	
	
	
}