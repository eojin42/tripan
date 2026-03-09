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
    private String placeName;   // place.place_name
    private String address;     // place.address
    private String imageUrl;    // place.image_url
    private String category;    // place.category (ATTRACTION/ACCOMMODATION)
    private LocalDateTime createdAt;
}
