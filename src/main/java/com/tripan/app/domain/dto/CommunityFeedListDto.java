package com.tripan.app.domain.dto;

import lombok.Data;

@Data
public class CommunityFeedListDto {
    private Long postId;
    private String memberId;
    private String content;
    private String imageUrl;
    private Integer viewCount;
    private Integer likeCount;
    private String createdAt;
    private String nickname;
    private String profileImage;
    private Long tripId;
    private String tripName;
    private Integer totalBudget;
    
    private Integer isFollowing;
    
}