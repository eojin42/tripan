package com.tripan.app.domain.dto;

import java.util.List;

import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

@Getter
@Setter
@ToString
public class AdSearchConditionDto {
    private String region;
    private String checkin;
    private String checkout;
    private int adult;
    private int child;

    private Integer minPrice;
    private Integer maxPrice;
    
    private List<String> accTypes;

    private List<String> accFacilities; 
    private List<String> roomFacilities; 
}
