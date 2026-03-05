package com.tripan.app.trip.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.transaction.annotation.Transactional;

import com.tripan.app.trip.domian.entity.ItineraryItem;

import java.util.List;
import java.time.LocalTime;

// 세부 장소/일정 관리 
public interface ItineraryItemRepository extends JpaRepository<ItineraryItem, Long> {

    // [내부 로직용] 담아오기 시 특정 일차의 아이템 긁어오기
    List<ItineraryItem> findByDayId(Long dayId);

    // [순서 변경] 드래그 앤 드롭으로 순서(visitOrder)만 휙 바꿀 때
    @Modifying
    @Transactional
    @Query("UPDATE ItineraryItem i SET i.visitOrder = :visitOrder WHERE i.itemId = :itemId")
    void updateVisitOrder(@Param("itemId") Long itemId, @Param("visitOrder") Integer visitOrder);

    // [상세 수정] 특정 장소의 방문 시간이나 메모만 딱 찝어서 바꿀 때
    @Modifying
    @Transactional
    @Query("UPDATE ItineraryItem i SET i.startTime = :startTime, i.memo = :memo WHERE i.itemId = :itemId")
    void updateItemDetails(@Param("itemId") Long itemId, @Param("startTime") LocalTime startTime, @Param("memo") String memo);

/*
일정 편집 로직 정리 (나중에 삭제할거)

1. 새로운 장소 추가하기
프론트에서 day_id와 trip_place_id(카카오맵 장소 ID 또는 직접 만든 장소 ID)를 넘김.
백엔드는 new ItineraryItem()을 만들어서 맨 마지막 순서(visit_order)로 세팅 후 save()

2. 드래그 앤 드롭으로 순서 바꾸기 
만약 에버랜드(2번)를 3번으로 내리면, 바뀐 전체 순서 리스트를 배열로 백엔드에 쏴줌.
예: [{itemId: 10, visitOrder: 1}, {itemId: 12, visitOrder: 2}, {itemId: 11, visitOrder: 3}]
백엔드는 이 배열을 받아서 for문을 돌리며 아까 만든 updateVisitOrder(아이템ID, 새 순서)를 반영.

3. 시간이나 메모 수정하기
사용자가 에버랜드 항목을 클릭해서 "오후 2시 방문"으로 시작시간이나, "츄러스 꼭 먹기"라고 메모를 쓰면
프론트에서 item_id, start_time, memo를 넘겨주면 백엔드는 updateItemDetails(...) 쿼리 한 방으로 해당 컬럼 2개만 깔끔하게 덮어씌움.

4. 일정 삭제하기 (Delete)
프론트에서 item_id를 던지면 deleteById()로 삭제

*/
    
}