package com.tripan.app.partner.domain.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PartnerFacilityUpdateDto {
    private Long placeId;          // 대상 숙소 ID
    private Integer isActive;      // PLACE 테이블의 노출 여부 (0: 비노출, 1: 노출)
    
    private String checkinTime;
    private String checkoutTime;
    private String parkinglodging;
    
    private Integer fitness;
    private Integer chkcooking;
    private Integer barbecue;
    private Integer beverage;
    private Integer karaoke;
    private Integer publicpc;
    private Integer sauna;
    
    private String otherFacility;  // 기타 부대시설 이름
}