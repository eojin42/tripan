package com.tripan.app.service;

import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;

import com.tripan.app.domain.dto.CommunityFeedListDto;
import com.tripan.app.domain.dto.CommunityFeedWriteRequestDto;

public interface CommunityFeedService {
	
	void insertFeed(CommunityFeedWriteRequestDto dto, Long memberId) throws Exception;
	public String toggleFollow(Long followerId, Long followingId);
	List<CommunityFeedListDto> getFeedList(Long loginMemberId);
}