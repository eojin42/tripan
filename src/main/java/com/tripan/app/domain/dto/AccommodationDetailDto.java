package com.tripan.app.domain.dto;

import java.util.List;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class AccommodationDetailDto extends AccommodationDto{
	private String imageUrl;
	
	private String description;       // 숙소 상세 설명
    private String checkinTime;       // 체크인 시간
    private String checkoutTime;      // 체크아웃 시간
    
    private List<String> images;      // 숙소 이미지 URL 리스트
    private List<RoomDto> rooms;      // 해당 숙소의 객실 리스트
    
    private int isBookmarked;
    private String parkinglodging;
    
    private Integer isActive;
    
    private Integer fitness;
    private Integer chkcooking;
    private Integer barbecue;
    private Integer beverage;
    private Integer karaoke;
    private Integer publicpc;
    private Integer sauna;
    
    private String otherFacility;
    private List<String> tags;
}
