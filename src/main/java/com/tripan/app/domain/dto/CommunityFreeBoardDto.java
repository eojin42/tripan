package com.tripan.app.domain.dto;

import java.util.List;

import org.springframework.web.multipart.MultipartFile;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class CommunityFreeBoardDto {
    private Long boardId;
    private Long memberId;      // 작성자 FK
    private String category;    // tip, question, review, etc
    private String title;
    private String content;     
    private String thumbnailUrl;
    private int viewCount;
    private int likeCount;
    private int replyCount;
    private String createdAt;   // TIMESTAMP
    private String updatedAt;

    private String nickname;
    private String profilePhoto;
    
    private Long tripId;
    private String tripName;
    private String tripDate;
    
    private int status;
    
    private List<MultipartFile> files;
}