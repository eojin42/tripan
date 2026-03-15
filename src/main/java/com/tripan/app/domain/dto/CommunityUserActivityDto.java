package com.tripan.app.domain.dto;

import lombok.Data;

@Data
public class CommunityUserActivityDto {
    private String activityType; 
    private String icon;        
    private String metaInfo;    
    private String targetTitle;  
    private String content;      
    private String createdAt;    
    private Long targetUrlId;   
}