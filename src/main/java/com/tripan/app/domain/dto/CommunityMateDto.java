package com.tripan.app.domain.dto;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class CommunityMateDto {
    private Long mateId;
    private Long memberId;
    private Long regionId;
    private Long tripId;       
    
    private int targetCount;
    private String startDate;  
    private String endDate;
    private String title;
    private String content;
    private String tags;       // 자유 해시태그 (예: #20대,#맛집)
    private String status;     // OPEN / CLOSED 
    private int viewCount;
    private String createdAt;

    private String nickname;
    private String profilePhoto;
    private String sidoName;    	
    
    private int postStatus;
}