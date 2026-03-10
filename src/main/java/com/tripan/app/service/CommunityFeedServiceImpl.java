package com.tripan.app.service; 

import java.io.File;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.tripan.app.domain.dto.CommunityFeedListDto;
import com.tripan.app.domain.dto.CommunityFeedWriteRequestDto;
import com.tripan.app.mapper.CommunityFeedMapper;
import com.tripan.app.service.CommunityFeedService;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor 
public class CommunityFeedServiceImpl implements CommunityFeedService {

    private final CommunityFeedMapper feedMapper;

    @Value("${file.upload-root}")
    private String uploadRoot;

    @Override
    public void insertFeed(CommunityFeedWriteRequestDto dto, Long memberId) throws Exception {
        
        String finalContent = dto.getContent();
        if (dto.getTags() != null && !dto.getTags().trim().isEmpty()) {
            finalContent = finalContent + "\n\n" + dto.getTags().trim(); 
        }

        Long finalTripId = null;
        if (dto.getTripId() != null && !dto.getTripId().isEmpty()) {
            String numericPart = dto.getTripId().replaceAll("[^0-9]", "");
            if (!numericPart.isEmpty()) {
                finalTripId = Long.parseLong(numericPart); 
            }
        }

        String firstImageUrl = null;
        if (dto.getFiles() != null && !dto.getFiles().isEmpty()) {
            MultipartFile firstFile = dto.getFiles().get(0); 
            if(!firstFile.isEmpty()) {
                String originalFilename = firstFile.getOriginalFilename();
                String savedFilename = UUID.randomUUID().toString() + "_" + originalFilename;
                
                String feedUploadPath = uploadRoot + "/feed/";
                File destDir = new File(feedUploadPath);
                if (!destDir.exists()) { destDir.mkdirs(); }
                
                File destFile = new File(destDir, savedFilename);
                firstFile.transferTo(destFile); 
                firstImageUrl = savedFilename; 
            }
        }

        Map<String, Object> paramMap = new HashMap<>();
        paramMap.put("memberId", memberId);
        paramMap.put("tripId", finalTripId); 
        paramMap.put("content", finalContent);
        paramMap.put("imageUrl", firstImageUrl);

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
    
}