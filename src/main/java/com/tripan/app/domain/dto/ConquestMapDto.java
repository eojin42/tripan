package com.tripan.app.domain.dto;

import java.util.List;

import org.springframework.web.multipart.MultipartFile;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ConquestMapDto {
	private Long conquestMapId;
	private Long memberId;
	private Long regionId;
    private String sigunguName; // 시/군/구 이름
    private String colorCode;
    private String startDate;   // yyyy-MM-dd 형태
    private String endDate;
    private String memo;
    private String photoPath;
    private String conquestDate; // 등록 날짜 (조회용)
    
    private Long photoId;
    private String photoUrl;
    private List<MultipartFile> photos;
    private List<ConquestMapDto> photoList;
}