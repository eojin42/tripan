package com.tripan.app.mapper;

import com.tripan.app.trip.domain.entity.TripChecklist;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;
import java.util.Map;

@Mapper
public interface ChecklistMapper {

    List<Map<String, Object>> selectByTripId(@Param("tripId") Long tripId);

    /** Controller에서 TripChecklist 엔티티로 호출 → XML에서 #{tripId}, #{itemName} 등으로 참조 */
    void insertItem(TripChecklist item);

    void toggleItem(@Param("checklistId") Long checklistId);

    void deleteItem(
        @Param("checklistId") Long checklistId,
        @Param("tripId")      Long tripId
    );

    List<String> selectCategories(@Param("tripId") Long tripId);
}
