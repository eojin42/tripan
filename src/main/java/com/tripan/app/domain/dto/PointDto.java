package com.tripan.app.domain.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class PointDto {
	private Long pointId;     
    private Long memberId; 
    private String orderId;    
    private String changeReason; 
    private Long pointAmount;    
    private Long remPoint;      
    private String regDate;
    
    public String getType() {
        return pointAmount > 0 ? "earn" : "use";
    }
}
