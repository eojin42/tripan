package com.tripan.app.domain.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class RoomDto {
	private String placeName;
	
    private String roomId;
    private String roomName;
    private Integer roomBaseCount; 
    private Integer maxCapacity;   
    private Integer amount;       
    private String roomIntro;      
    
    private String roomImageUrl;
    
    private int roomCount;           
    private boolean available = true;
    
    private int remainingCount;
}