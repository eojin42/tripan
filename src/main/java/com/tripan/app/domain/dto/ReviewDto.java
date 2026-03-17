package com.tripan.app.domain.dto;

import java.util.List;

import org.springframework.web.multipart.MultipartFile;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ReviewDto {
	private Long reviewId;
    private Long reservationId;
    private Long memberId;      
    private Long placeId;
    private String placeName;      
    private int rating;         
    private String content;    
    private String startDate;       
    private String endDate;       
    private long helpfulCount;   
    private String createdAt;
    private String updatedAt;
    
    private String mode;
    
    private List<MultipartFile> uploadFiles; 
    
    private String memberName; 
    private String roomName;   
    
    private List<String> imageUrls;
}
