package com.tripan.app.repository.trip;

import org.springframework.data.jpa.repository.JpaRepository;

import com.tripan.app.domain.trip.entity.TripScrap;

// 여행 워크스페이스 담아오기(복제)
public interface TripScrapRepository extends JpaRepository<TripScrap, Long> {

/*
- 로직정리 (나중에 삭제할거임)

1단계: 새로운 '껍데기(Trip)' 창조
원본 여행의 기본 정보(제목, 시작/종료일, 썸네일, 여행 유형)를 복사하여 새로운 Trip INSERT.
상태는 'PLANNING', 스크랩 수(scrap_count)는 0으로 세팅.
제목 뒤에 " (복사본)" 또는 " (버전2)" 추가.
복사된 새 여행의 original_trip_id 컬럼에 원본 여행의 trip_id를 INSERT. (출처 추적용)


2단계: 복제한 사람을 '방장'으로 임명 
새로 발급된 Trip ID와 복제한 유저의 Member ID를 매핑하여 TripMember 테이블에 INSERT.
권한(role)은 무조건 'OWNER'로 설정.


3단계: 여행 메타 데이터(태그) 복사 & 찌꺼기 제외
원본 여행에 달린 태그(TripTag)는 새 여행에도 동일하게 INSERT.
원본에 있던 투표(Vote), 체크리스트(TripChecklist) 데이터는 개인화된 정보이므로 복사하지 않고 버림.


4단계: 일자(Day) 뼈대 복사하기
원본의 TripDay 목록을 조회하여, 새 Trip ID를 바라보는 새로운 TripDay들을 INSERT. (새로운 day_id 발급)


5단계: 알맹이(Item) 복사 및 '나만의 장소' 연결
원본 일자 안의 ItineraryItem들을 조회하여 새로운 day_id에 맞춰 INSERT.
방문 시간, 메모, 순서(visit_order) 등은 그대로 복사.
[나만의 장소 처리] API 장소든, 위도/경도를 직접 찍은 커스텀 장소든 상관없이 
	     기존 trip_place_id만 그대로 복사해서 연결. 
[필터링] Item 에 달린 이미지(ItineraryImage)는 복사하지 않고 버림.

5단계: 스크랩 수 수정 (TripScrap)
원본 Trip의 scrap_count를 +1 UPDATE.
 */
}

