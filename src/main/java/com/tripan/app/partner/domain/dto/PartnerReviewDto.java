package com.tripan.app.partner.domain.dto;

import lombok.Data;

@Data
public class PartnerReviewDto {
    private Long reviewId;
    private Long placeId;
    private Long memberId;
    
    private Integer rating;       // 별점
    private String content;       // 리뷰 내용
    private String createdAt;     // 작성일
    
    private String memberName;    // 작성자 닉네임
    private String roomName;      // 이용한 객실명
}