package com.tripan.app.service; 

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.tripan.app.domain.dto.CommunityFeedCommentDto;
import com.tripan.app.domain.dto.CommunityFeedListDto;
import com.tripan.app.domain.dto.CommunityFeedWriteRequestDto;
import com.tripan.app.domain.dto.MemberDto;
import com.tripan.app.mapper.CommunityFeedMapper;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
@RequiredArgsConstructor 
public class CommunityFeedServiceImpl implements CommunityFeedService {

    private final CommunityFeedMapper feedMapper;

    @Value("${file.upload-root}")
    private String uploadRoot;

    @Override
    @Transactional
    public void insertFeed(CommunityFeedWriteRequestDto dto, Long memberId) throws Exception {
        String finalContent = dto.getContent();
        if (dto.getTags() != null && !dto.getTags().trim().isEmpty()) {
            finalContent += "\n\n" + dto.getTags().trim();
        }

        String savedImageUrls = null;
        
        if (dto.getFiles() != null && !dto.getFiles().isEmpty()) {
            List<String> fileNameList = new ArrayList<>();
            String feedUploadPath = uploadRoot + "/feed/";
            File destDir = new File(feedUploadPath);
            if (!destDir.exists()) destDir.mkdirs();

            int limit = Math.min(dto.getFiles().size(), 4);
            for (int i = 0; i < limit; i++) {
                MultipartFile file = dto.getFiles().get(i);
                if (!file.isEmpty()) {
                	String originalFilename = file.getOriginalFilename();

                	String cleanFilename = "feed_img"; 
                	if (originalFilename != null) {
                	    cleanFilename = originalFilename.replaceAll("[^a-zA-Z0-9가-힣\\.\\-_]", "_");
                	}

                	String savedFilename = UUID.randomUUID().toString() + "_" + cleanFilename;
                	file.transferTo(new File(destDir, savedFilename));
                    fileNameList.add(savedFilename);
                }
            }
            if (!fileNameList.isEmpty()) {
                savedImageUrls = String.join(",", fileNameList);
            }
        }

        Map<String, Object> paramMap = new HashMap<>();
        paramMap.put("memberId", memberId);
        paramMap.put("tripId", dto.getTripId());
        paramMap.put("content", finalContent);
        paramMap.put("imageUrl", savedImageUrls); 

        feedMapper.insertFeedPost(paramMap);
    }
    
    @Override
    @Transactional
    public String toggleFollow(Long followerId, Long followingId) {
        int count = feedMapper.checkFollow(followerId, followingId);
        if (count > 0) {
            feedMapper.deleteFollow(followerId, followingId);
            return "unfollowed";
        } else {
            feedMapper.insertFollow(followerId, followingId);
            return "followed";
        }
    }

    @Override
    public List<CommunityFeedListDto> getFeedList(Long loginMemberId) {
        return feedMapper.getFeedList(loginMemberId);
    }
    
    @Override
    @Transactional
    public Map<String, Object> toggleFeedLike(Long postId, Long memberId) {
        Map<String, Object> params = new HashMap<>();
        params.put("postId", postId);
        params.put("memberId", memberId);
        
        int isLiked = feedMapper.checkFeedLike(params);
        String status;
        int amount;
        
        if (isLiked > 0) {
            feedMapper.deleteFeedLike(params);
            amount = -1; 
            status = "unliked";
        } else { 
            feedMapper.insertFeedLike(params);
            amount = 1; 
            status = "liked";
        }
        
        feedMapper.updateFeedLikeCount(postId, amount);
        
        int newCount = feedMapper.getFeedLikeCount(postId);
        
        return Map.of("status", status, "count", newCount);
    }
    
    @Override
    public List<CommunityFeedCommentDto> getFeedComments(Long postId) {
        return feedMapper.getFeedComments(postId);
    }

    @Override
    @Transactional
    public void insertFeedComment(CommunityFeedCommentDto dto) throws Exception {
        feedMapper.insertFeedComment(dto);
    }
    
    @Override
    @Transactional
    public boolean deleteFeedComment(Long commentId, Long memberId) {
        int result = feedMapper.deleteFeedComment(commentId, memberId);
        return result > 0;
    }
    
    @Override
    @Transactional
    public boolean deleteFeed(Long postId, Long currentMemberId) {
        Long writerId = feedMapper.getFeedWriterId(postId);
        
        if (writerId == null) {
            log.warn("존재하지 않는 게시글 삭제 시도 - postId: {}", postId);
        }
        
        if (!writerId.equals(currentMemberId)) {
            log.warn("게시글 삭제 권한 없음 - postId: {}, 요청자: {}, 실제작성자: {}", postId, currentMemberId, writerId);
            return false; 
        }
        
        int result = feedMapper.deleteFeedPost(postId);
        
        return result > 0;
    }
    
    @Override
    public int getMyFeedCount(Long memberId) {
        return feedMapper.countMyFeeds(memberId);
    }
    
    @Override
    public CommunityFeedListDto getFeedById(Long postId) {
        return feedMapper.selectFeedById(postId);
    }

    @Override
    @Transactional
    public void updateFeed(CommunityFeedWriteRequestDto dto, Long memberId) throws Exception {
        String finalContent = dto.getContent();
        if (dto.getTags() != null && !dto.getTags().trim().isEmpty()) {
            finalContent += "\n\n" + dto.getTags().trim();
        }

        String savedImageUrls = null;
        if (dto.getFiles() != null && !dto.getFiles().isEmpty()) {
            List<String> fileNameList = new ArrayList<>();
            String feedUploadPath = uploadRoot + "/feed/";
            File destDir = new File(feedUploadPath);
            if (!destDir.exists()) destDir.mkdirs();

            for (MultipartFile file : dto.getFiles()) {
                if (!file.isEmpty()) {
                    String savedFilename = UUID.randomUUID().toString() + "_" + file.getOriginalFilename();
                    file.transferTo(new File(destDir, savedFilename));
                    fileNameList.add(savedFilename);
                }
            }
            if (!fileNameList.isEmpty()) savedImageUrls = String.join(",", fileNameList);
        } else {
            CommunityFeedListDto origin = feedMapper.selectFeedById(dto.getPostId());
            savedImageUrls = origin.getImageUrl();
        }

        Map<String, Object> paramMap = new HashMap<>();
        paramMap.put("postId", dto.getPostId());
        paramMap.put("memberId", memberId);
        paramMap.put("tripId", dto.getTripId());
        paramMap.put("content", finalContent);
        paramMap.put("imageUrl", savedImageUrls);

        feedMapper.updateFeedPost(paramMap);
    }
    
    @Override
    public MemberDto getMemberInfo(Long memberId) {
        return feedMapper.getMemberInfo(memberId);
    }

    @Override
    public List<CommunityFeedListDto> getUserFeedList(Long targetMemberId, Long loginMemberId) {
        Map<String, Object> params = new HashMap<>();
        params.put("targetMemberId", targetMemberId);
        params.put("loginMemberId", loginMemberId); // 로그인 안 했으면 -1 같은 값이 들어옴
        
        return feedMapper.getUserFeedList(params);
    }

    
    
}