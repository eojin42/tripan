package com.tripan.app.admin.domain.dto;

import lombok.Getter;
import lombok.Setter;

@Getter 
@Setter
public class BookingResponseDto {
    private Long id;           
    private String resId;
    
    private String roomName;
    private String username;
    
    private String duration;
    private String totalPrice;
    
    // UI 제어 데이터
    private String statusText;
    private String statusClass;
}