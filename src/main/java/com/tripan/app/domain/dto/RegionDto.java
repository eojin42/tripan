package com.tripan.app.domain.dto;

import lombok.Data;

@Data
public class RegionDto {
    private Long regionId;        
    private String sidoName;    
    private String sigunguName;  
    private Integer apiAreaCode; 
    private Integer apiSigunguCode; 
}