package com.tripan.app.service;

import java.util.List;
import java.util.Set;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.tripan.app.domain.dto.BadgeInfoDto;
import com.tripan.app.domain.dto.BookmarkDto;
import com.tripan.app.domain.dto.FollowDto;
import com.tripan.app.domain.dto.MemberDto;
import com.tripan.app.domain.dto.MyPageSummaryDto;
import com.tripan.app.domain.dto.MyPageSummaryDto.ActivityItem;
import com.tripan.app.domain.dto.MyReviewDto;
import com.tripan.app.domain.dto.MyTripDto;
import com.tripan.app.mapper.MyPageMapper;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@Slf4j
@RequiredArgsConstructor
public class MyPageServiceImpl implements MyPageService{
	
	private final MyPageMapper mapper;
	
	@Override
	public MyPageSummaryDto getMyPageSummary(Long memberId) {
		
		return mapper.selectMyPageSummary(memberId);
	}

	@Override
	public MyPageSummaryDto getTravelStats(Long memberId) {
		return mapper.selectTravelStats(memberId);
	}

	@Override
	public List<MyPageSummaryDto> getVisitedRegions(Long memberId) {
		List<MyPageSummaryDto> list = mapper.selectVisitedRegions(memberId);
		
		return list;
	}

	@Override
	public Set<Long> getVisitedRegionIds(Long memberId) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public List<MyTripDto> getMyTrips(Long memberId) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public List<MyReviewDto> getMyReviews(Long memberId) {
		// TODO Auto-generated method stub
		return null;
	}

	@Transactional
	@Override
	public void deleteReview(Long memberId, Long reviewId) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public List<BookmarkDto> getMyBookmarks(Long memberId) {
		// TODO Auto-generated method stub
		return null;
	}

	@Transactional
	@Override
	public void deleteBookmark(Long memberId, Long bookmarkId) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public List<BadgeInfoDto> getMyBadges(Long memberId) {
		// TODO Auto-generated method stub
		return null;
	}

	@Transactional
	@Override
	public void updateEquippedBadge(Long memberId, Long badgeId) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public List<FollowDto> getFollowingList(Long memberId) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public List<FollowDto> getFollowerList(Long memberId) {
		// TODO Auto-generated method stub
		return null;
	}

	@Transactional
	@Override
	public void unfollow(Long followerId, Long followingId) {
		// TODO Auto-generated method stub
		
	}

	@Transactional
	@Override
	public void updateProfile(Long memberId, MemberDto dto) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public List<ActivityItem> getActivitySummary(Long memberId) {
		// TODO Auto-generated method stub
		return null;
	}

}
