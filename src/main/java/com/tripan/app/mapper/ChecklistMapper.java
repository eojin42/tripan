package com.tripan.app.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;
import java.util.Map;

@Mapper
public interface ChecklistMapper {

    List<Map<String, Object>> selectByTripId(@Param("tripId") Long tripId);

    int insertItem(com.tripan.app.trip.domain.entity.TripChecklist item);

    void toggleItem(@Param("checklistId") Long checklistId);

    void deleteItem(
        @Param("checklistId") Long checklistId,
        @Param("tripId")      Long tripId
    );

    List<String> selectCategories(@Param("tripId") Long tripId);
}
