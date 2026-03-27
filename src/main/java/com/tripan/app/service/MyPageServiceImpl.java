package com.tripan.app.service;

import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.tripan.app.domain.dto.BadgeInfoDto;
import com.tripan.app.domain.dto.BookmarkDto;
import com.tripan.app.domain.dto.ConquestMapDto;
import com.tripan.app.domain.dto.FollowDto;
import com.tripan.app.domain.dto.MemberDto;
import com.tripan.app.domain.dto.MyPageSummaryDto;
import com.tripan.app.domain.dto.MyPageSummaryDto.ActivityItem;
import com.tripan.app.domain.dto.MyReviewDto;
import com.tripan.app.mapper.MyPageMapper;
import com.tripan.app.repository.BookmarkRepository;
import com.tripan.app.repository.FollowRepository;
import com.tripan.app.repository.Member2Repository;
import com.tripan.app.repository.MemberBadgeRepository;
import com.tripan.app.repository.PlaceReviewRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@Slf4j
@RequiredArgsConstructor
public class MyPageServiceImpl implements MyPageService {

    private final MyPageMapper mapper;
    private final Member2Repository member2Repository;
    private final BookmarkRepository bookmarkRepository;
    private final MemberBadgeRepository memberBadgeRepository;
    private final FollowRepository followRepository;
    private final PlaceReviewRepository placeReviewRepository;

    // 마이페이지 종합 요약
    @Override
    public MyPageSummaryDto getMyPageSummary(Long memberId) {
        try {
            return mapper.selectMyPageSummary(memberId);
        } catch (Exception e) {
            log.info("getMyPageSummary : ", e);
            return null;
        }
    }

    // 여행 통계
    @Override
    public MyPageSummaryDto getTravelStats(Long memberId) {
        try {
            return mapper.selectTravelStats(memberId);
        } catch (Exception e) {
            log.info("getTravelStats : ", e);
            return null;
        }
    }

    // 방문 지역 목록
    @Override
    public List<MyPageSummaryDto> getVisitedRegions(Long memberId) {
        try {
            return mapper.selectVisitedRegions(memberId);
        } catch (Exception e) {
            log.info("getVisitedRegions : ", e);
            return null;
        }
    }

    // 방문 지역 ID 목록 (JSP 조건 렌더링용)
    @Override
    public Set<Long> getVisitedRegionIds(Long memberId) {
        try {
            return new HashSet<>(mapper.selectVisitedRegionIds(memberId));
        } catch (Exception e) {
            log.info("getVisitedRegionIds : ", e);
            return new HashSet<>();
        }
    }

    // 내 리뷰 목록
    @Override
    public List<MyReviewDto> getMyReviews(Long memberId) {
        try {
            return mapper.selectMyReviews(memberId);
        } catch (Exception e) {
            log.info("getMyReviews : ", e);
            return null;
        }
    }

    // 리뷰 삭제 (본인 것만)
    @Transactional
    @Override
    public void deleteReview(Long memberId, Long reviewId) {
        try {
            int result = placeReviewRepository.deleteByReviewIdAndMemberId(reviewId, memberId);
            if (result == 0) throw new IllegalArgumentException("삭제 권한이 없거나 존재하지 않는 리뷰입니다.");
        } catch (Exception e) {
            log.info("deleteReview : ", e);
            throw e;
        }
    }

    // 찜 목록 조회 (type: PLACE / ACCOMMODATION / null=전체)
    @Override
    public List<BookmarkDto> getMyBookmarks(Long memberId, String type) {
        try {
        	List<BookmarkDto> list = mapper.selectMyBookmarks(memberId, type);
            return list;
        } catch (Exception e) {
            log.info("getMyBookmarks : ", e);
            return null;
        }
    }

    // 찜 해제 (본인 것만)
    @Transactional
    @Override
    public void deleteBookmark(Long memberId, Long bookmarkId) {
        try {
            int result = bookmarkRepository.deleteByBookmarkIdAndMemberId(bookmarkId, memberId);
            if (result == 0) throw new IllegalArgumentException("삭제 권한이 없거나 존재하지 않는 북마크입니다.");
        } catch (Exception e) {
            log.info("deleteBookmark : ", e);
            throw e;
        }
    }

    // 배지 목록 조회
    @Override
    public List<BadgeInfoDto> getMyBadges(Long memberId) {
        try {
            return mapper.selectAllBadgesWithStatus(memberId);
        } catch (Exception e) {
            log.info("getMyBadges : ", e);
            return null;
        }
    }

    // 배지 장착
    @Transactional
    @Override
    public void updateEquippedBadge(Long memberId, Long badgeId) {
        try {
            // 획득한 배지인지 검증
            boolean isEarned = memberBadgeRepository.existsByMemberIdAndBadgeId(memberId, badgeId);
            if (!isEarned) throw new IllegalArgumentException("획득하지 않은 배지는 장착할 수 없습니다.");
            member2Repository.updateEquippedBadge(memberId, badgeId);
        } catch (Exception e) {
            log.info("updateEquippedBadge : ", e);
            throw e;
        }
    }

    // 팔로잉 목록
    @Override
    public List<FollowDto> getFollowingList(Long memberId) {
        try {
            return mapper.selectFollowingList(memberId);
        } catch (Exception e) {
            log.info("getFollowingList : ", e);
            return null;
        }
    }

    // 팔로워 목록
    @Override
    public List<FollowDto> getFollowerList(Long memberId) {
        try {
            return mapper.selectFollowerList(memberId);
        } catch (Exception e) {
            log.info("getFollowerList : ", e);
            return null;
        }
    }

    // 언팔로우
    @Transactional
    @Override
    public void unfollow(Long followerId, Long followingId) {
        try {
            int result = followRepository.deleteByFollowerIdAndFollowingId(followerId, followingId);
            if (result == 0) throw new IllegalArgumentException("존재하지 않는 팔로우입니다.");
        } catch (Exception e) {
            log.info("unfollow : ", e);
            throw e;
        }
    }

    // 프로필 수정
    @Transactional
    @Override
    public void updateProfile(Long memberId, MemberDto dto) {
        try {
            member2Repository.updateProfile(
                memberId,
                dto.getNickname(),
                dto.getBio(),
                dto.getPhoneNumber(),
                dto.getPreferredRegion()
            );
        } catch (Exception e) {
            log.info("updateProfile : ", e);
            throw e;
        }
    }

    // 활동 요약
    @Override
    public List<ActivityItem> getActivitySummary(Long memberId) {
        try {
        	List<ActivityItem> list = mapper.selectActivitySummary(memberId);
            return list;
        } catch (Exception e) {
            log.info("getActivitySummary : ", e);
            return null;
        }
    }
	
	// 예약 가져오기
    @Override
    public List<Map<String, Object>> getMyBookings(Long memberId) {
        try {
            return mapper.getMyBookings(memberId);
        } catch (Exception e) {
            log.info("getMyBookings : ", e);
            return List.of();
        }
    }

	@Override
	public List<ConquestMapDto> getVisitedRegionsData(Long memberId) {
		try {
			List<ConquestMapDto> list = mapper.selectVisitedRegionsData(memberId);
	        // 각 지역마다 사진 목록 별도 조회
	        for (ConquestMapDto dto : list) {
	            List<ConquestMapDto> photos = mapper.selectPhotosByConquestMapId(dto.getConquestMapId());
	            dto.setPhotoList(photos);
	        }
	        return list;
        } catch (Exception e) {
            log.info("getVisitedRegionsData : ", e);
            return List.of();
        }
	}

	@Override
	public void saveVisitedRegion(ConquestMapDto dto) {
		try {
            // 프론트에서 넘어온 지역명("강남구")으로 DB의 region_id 조회
            Long regionId = mapper.selectRegionIdByName(dto.getSigunguName());
            if (regionId == null) {
                throw new IllegalArgumentException("존재하지 않는 지역명입니다: " + dto.getSigunguName());
            }
            dto.setRegionId(regionId); // 알아낸 ID 세팅

            // 해당 ID로 이미 저장된 기록이 있는지 확인
            int count = mapper.checkRegionExists(dto.getMemberId(), regionId);
            
            // 분기 처리 (있으면 Update, 없으면 Insert)
            if (count > 0) {
                mapper.updateRegionData(dto);
                Long conquestMapId = mapper.selectConquestMapId(dto.getMemberId(), regionId);
                dto.setConquestMapId(conquestMapId);
            } else {
                mapper.insertRegionData(dto);
            }
        } catch (Exception e) {
            log.info("saveVisitedRegion : ", e);
            throw e;
        }
		
	}

	@Override
	public void deleteVisitedRegion(Long memberId, String sigunguName) {
		try {
            Long regionId = mapper.selectRegionIdByName(sigunguName);
            if (regionId != null) {
                mapper.deleteRegionData(memberId, regionId);
            }
        } catch (Exception e) {
            log.info("deleteVisitedRegion : ", e);
            throw e;
        }
    }
	
	@Override
	@Transactional
	public void savePhoto(Long memberId, Long conquestMapId, String photoUrl) {
	    // 본인 소유 검증
	    ConquestMapDto photo = new ConquestMapDto();
	    photo.setConquestMapId(conquestMapId);
	    photo.setPhotoUrl(photoUrl);
	    mapper.insertPhoto(photo);
	}
	
	@Override
	@Transactional
	public void deletePhoto(Long memberId, Long photoId) {
	    int result = mapper.deletePhoto(photoId, memberId);
	    if (result == 0) {
	        throw new IllegalArgumentException("삭제 권한이 없거나 존재하지 않는 사진입니다.");
	    }
	}
	
	// 미작성 리뷰 목록
	@Override
	public List<Map<String, Object>> getPendingReviews(Long memberId) {
	    try {
	        return mapper.selectPendingReviews(memberId);
	    } catch (Exception e) {
	        log.info("getPendingReviews : ", e);
	        return List.of();
	    }
	}
	 
	// 좋아요한 것들
	@Override
	public List<Map<String, Object>> getMyLikes(Long memberId, String type) {
	    try {
	        return mapper.selectMyLikes(memberId, type);
	    } catch (Exception e) {
	        log.info("getMyLikes : ", e);
	        return List.of();
	    }
	}
	 
	// 좋아요 취소
		@Transactional
		@Override
		public void deleteLike(Long memberId, Long likeId) {
		    try {
		        int result = mapper.deleteLike(memberId, likeId);
		        if (result == 0) throw new IllegalArgumentException("취소 권한이 없거나 존재하지 않는 좋아요입니다.");
		    } catch (Exception e) {
		        log.info("deleteLike : ", e);
		        throw e;
		    }
		}
	
	// 리뷰 수정
	@Transactional
	@Override
	public void updateReview(Long memberId, Long reviewId, int rating, String content) {
	    try {
	        int result = mapper.updateMyReview(memberId, reviewId, rating, content);
	        if (result == 0) throw new IllegalArgumentException("수정 권한이 없거나 존재하지 않는 리뷰입니다.");
	    } catch (Exception e) {
	        log.info("updateReview : ", e);
	        throw e;
	    }
	}
	 
	
	
}