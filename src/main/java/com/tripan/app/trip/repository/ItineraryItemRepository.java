package com.tripan.app.trip.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.transaction.annotation.Transactional;

import com.tripan.app.trip.domain.entity.ItineraryItem;

import java.util.List;

public interface ItineraryItemRepository extends JpaRepository<ItineraryItem, Long> {

    // [내부 로직용] 담아오기 시 특정 일차의 아이템 긁어오기
    List<ItineraryItem> findByDayId(Long dayId);

    /**
     * itemId → dayId → TripDay.tripId 경로로 tripId 조회
     * WebSocket broadcast 시 어느 방으로 보낼지 알아야 함
     */
    @Query("SELECT d.tripId FROM TripDay d WHERE d.dayId = " +
           "(SELECT i.dayId FROM ItineraryItem i WHERE i.itemId = :itemId)")
    Long findTripIdByItemId(@Param("itemId") Long itemId);

    /**
     * [순서 변경] visitOrder는 LexoRank 방식 String ("000001", "000002" ...)
     * 기존 Integer 타입은 잘못됨 → String으로 수정
     */
    @Modifying
    @Transactional
    @Query("UPDATE ItineraryItem i SET i.visitOrder = :visitOrder WHERE i.itemId = :itemId")
    void updateVisitOrder(@Param("itemId") Long itemId, @Param("visitOrder") String visitOrder);

    // [상세 수정] 방문 시간 + 메모
    @Modifying
    @Transactional
    @Query("UPDATE ItineraryItem i SET i.startTime = :startTime, i.memo = :memo WHERE i.itemId = :itemId")
    void updateItemDetails(@Param("itemId") Long itemId,
                           @Param("startTime") String startTime,
                           @Param("memo") String memo);
}
