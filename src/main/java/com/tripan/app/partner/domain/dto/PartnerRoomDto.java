package com.tripan.app.partner.domain.dto;

import lombok.Data;

@Data
public class PartnerRoomDto {
    private String roomId;       // 객실 PK (VARCHAR)
    private Long placeId;        // 소속된 숙소 PK
    private String roomName;     // 객실명
    private Integer roombasecount; // 기준 인원
    private Integer maxCapacity; // 최대 인원
    private Integer roomCount;   // 보유 객실 수
    private Long amount;         // 기본 요금
    private String roomintro;    // 객실 소개
    private String rfId;         
}