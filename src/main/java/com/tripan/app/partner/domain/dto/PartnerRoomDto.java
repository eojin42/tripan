package com.tripan.app.partner.domain.dto;

import lombok.Data;

@Data
public class PartnerRoomDto {
    private String roomId;         // 객실 PK (VARCHAR)
    private Long placeId;          // 소속된 숙소 PK
    private String roomName;       // 객실명
    private Integer roombasecount; // 기준 인원
    private Integer maxCapacity;   // 최대 인원
    private Integer roomCount;     // 보유 객실 수
    private Long amount;           // 기본 요금
    private String roomintro;      // 객실 소개
    private String rfId;           // 객실 시설 테이블 PK (room_facility 연결용)
    
    
    
    private Integer isActive;      // 판매 상태 (1: 판매중, 0: 판매중지) 
    
    private Integer roomaircondition; // 에어컨
    private Integer roomtv;           // TV
    private Integer roominternet;     // 와이파이(인터넷)
    private Integer roombath;         // 욕조
    private Integer roomrefrigerator; // 냉장고
    
    private String imageUrl;
}