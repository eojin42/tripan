package com.tripan.app.domain.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ReviewStatsDto {
    private int totalCount;   
    private double avgRating;  
    private int count5;        
    private int count4;       
    private int count3;       
    private int count2;        
    private int count1;        
}