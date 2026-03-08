package com.tripan.app.domain.dto;

import java.time.LocalDateTime;

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
public class BookmarkDto {

    private Long   bookmarkId;
    private Long   placeId;
    private String placeName;
    private String placeAddress;
    private String placeCategory;       // 관광지 / 맛집 / 카페 등
    private String thumbnailUrl;
    private LocalDateTime createdAt;
}
