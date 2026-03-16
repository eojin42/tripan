package com.tripan.app.domain.dto;

import java.util.List;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ReviewDto {
	private Long          reviewId;
	 private Long          placeId;
	 private String        placeName;       // place 테이블 JOIN
	 private int           rating;          // 1~5
	 private String        content;
	 private String     	startDate;       // 방문 날짜
	 private String     	endDate;       // 방문 날짜
	 private long          helpfulCount;    // 도움됐어요 수
	 private String createdAt;
	 private String updatedAt;
	 
	 private String mode;              // "write" 또는 "update"
     private List<String> imageUrls;
}
 