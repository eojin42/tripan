package com.tripan.app.domain.dto;

import lombok.Data;
import org.springframework.web.multipart.MultipartFile;
import java.util.List;

@Data
public class CommunityFeedWriteRequestDto {
	private Long postId;
    private String content;      
    private String tags;        
    private String tripId;      
    private List<MultipartFile> files;
}