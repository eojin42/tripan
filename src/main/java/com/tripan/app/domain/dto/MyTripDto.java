package com.tripan.app.domain.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@Builder
@NoArgsConstructor 
@AllArgsConstructor
public class MyTripDto {

 // ── trip 테이블 ──
 private Long          tripId;
 private String        tripName;
 private String        tripType;         // 커플/가족/친구 등
 private LocalDateTime startDate;
 private LocalDateTime endDate;
 private String        status;           // PLANNING / ONGOING / COMPLETED
 private String        thumbnailUrl;
 private BigDecimal    totalBudget;
 private String        regionName;       // region 테이블 JOIN


 private String        myRole;           // OWNER / EDITOR / VIEWER
 private String        invitationStatus; // ACCEPTED / PENDING / DECLINED
 private int           memberCount;      // 동행 인원 수 (ACCEPTED 인원)
}
