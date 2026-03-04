package com.tripan.app.repository.trip;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.transaction.annotation.Transactional;

import com.tripan.app.domain.trip.entity.Trip;

// 여행 방 생성/수정/삭제 등 
public interface TripRepository extends JpaRepository<Trip, Long> {
    
	// 초대 코드로 여행 방 찾기(내부 로직용)
    Optional<Trip> findByInviteCode(String inviteCode);

    
    // 스크랩 수 +1 증가
    @Modifying
    @Transactional
    @Query("UPDATE Trip t SET t.scrapCount = t.scrapCount + 1 WHERE t.tripId = :tripId")
    void incrementScrapCount(@Param("tripId") Long tripId);
    
    // 여행 상태 변경 (예: PLANNING -> COMPLETED)
    @Modifying
    @Transactional
    @Query("UPDATE Trip t SET t.status = :status WHERE t.tripId = :tripId")
    void updateTripStatus(@Param("tripId") Long tripId, @Param("status") String status);
/*
 * 
- 여행 방 로직 (나중에 삭제할거) 

[여행 방 생성 로직]
1단계: 여행 껍데기(Trip) 생성
프론트에서 제목, 시작/종료일, 여행 유형, 선택한 도시 정보 수신.
서버에서 초대 링크 코드(invite_code) 무작위 문자열 자동 생성.
trip 테이블에 INSERT. 초기 상태(status)는 PLANNING, 공개 여부(is_public)는 0(비공개)으로 설정.

2단계: 생성자를 방장(OWNER)으로 등록
생성된 trip_id와 생성자의 member_id를 trip_member 테이블에 INSERT.
권한(role)은 OWNER, 초대 상태(invitation_status)는 ACCEPTED로 설정.

3단계: 여행 일차(TripDay) 자동 뼈대 구축
시작일과 종료일을 계산하여 총 여행 일수 파악.
해당 일수만큼 trip_day 테이블에 1일차, 2일차 등 반복하여 INSERT.
이후 일정 편집 시 이 뼈대를 기준으로 장소 추가 진행.

4단계: 테마 해시태그(TripTag) 매핑
전달받은 태그 배열을 순회하며 tag 테이블 조회.
존재하지 않는 태그는 tag 테이블에 새로 INSERT.
최종적으로 확보한 tag_id와 trip_id를 trip_tag 테이블에 매핑하여 INSERT.


[여행 방 수정 로직]
1단계: 기본 정보 수정
제목, 여행 유형, 상태 등 단순 텍스트 정보는 trip 테이블에서 UPDATE 처리.

2단계: 여행 기간(일차) 변경 시 데이터 동기화
수정된 시작일/종료일 기준으로 새로운 여행 일수 재계산.
기존 DB에 저장된 trip_day 총 개수와 비교.
일수가 늘어난 경우: 늘어난 일차만큼 trip_day 테이블에 추가 INSERT.
일수가 줄어든 경우: 초과된 후순위 일차의 trip_day 및 하위 등록된 장소(itinerary_item) 데이터 일괄 DELETE 처리. (프론트 단에서 사전 경고 필수)

3단계: 해시태그 수정
기존 trip_tag 테이블에서 해당 trip_id로 묶인 매핑 데이터를 전부 DELETE 처리하여 초기화.
새로 전달받은 태그 리스트를 생성 로직 4단계와 동일한 방식으로 다시 INSERT.


[여행 방 삭제 로직]
단일 삭제 처리
해당 trip_id에 종속된 하위 데이터(trip_member, trip_tag, trip_day, itinerary_item, trip_checklist 등)를 먼저 삭제하거나, JPA의 Cascade 기능을 활용하여 일괄 연쇄 삭제.
마지막으로 trip 테이블에서 해당 여행 데이터 DELETE.


[장소 및 추천 조회 로직 - MyBatis 전담]
카테고리 및 태그 기반 검색
관광지(ATTRACTION), 숙소(ACCOMMODATION), 식당(RESTAURANT) 등 카테고리별 장소 필터링.
사용자가 선택한 여행 테마(해시태그)와 연관성이 높은 장소 목록 추출.
이러한 복잡한 조회와 필터링은 JPA를 사용하지 않고 MyBatis XML 매퍼의 SELECT 쿼리를 통해 DTO로 직접 매핑하여 반환.
 
*/
    
}

