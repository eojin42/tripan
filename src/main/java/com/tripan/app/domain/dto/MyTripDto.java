package com.tripan.app.domain.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

//마이페이지 내 여행 일정 목록용
//→ TripDto와 차이:
// TripDto     : 일정 상세 (members, days, votes, checklists 등 전체 데이터)
// MyTripDto   : 마이페이지 목록 카드용 (trip_member 조인 필드 추가, 상세 제외)
//
//trip_member JOIN trip 조회
//→ trip, trip_member Entity는 일정팀 소유, 조회만
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
