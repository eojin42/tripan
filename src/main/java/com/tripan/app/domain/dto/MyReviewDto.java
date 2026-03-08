package com.tripan.app.domain.dto;

import java.time.LocalDate;
import java.time.LocalDateTime;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

//place_review 테이블 member_id 조회용
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MyReviewDto {

 private Long          reviewId;
 private Long          placeId;
 private String        placeName;       // place 테이블 JOIN
 private String        placeCategory;   // ATTRACTION / ACCOMMODATION / RESTAURANT
 private int           rating;          // 1~5
 private String        content;
 private String        images;          // CLOB, 이미지 URL 목록
 private LocalDate     visitDate;       // 방문 날짜
 private long          helpfulCount;    // 도움됐어요 수
 private LocalDateTime createdAt;
 private LocalDateTime updatedAt;
}