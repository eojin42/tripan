package com.tripan.app.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;
import java.util.Map;

@Mapper
public interface NotificationMapper {

    List<Map<String, Object>> selectByTripIdAndReceiver(
        @Param("tripId")   Long tripId,
        @Param("memberId") Long memberId
    );

    void markAsRead(@Param("notificationId") Long notificationId);

    void markAllAsRead(
        @Param("tripId")   Long tripId,
        @Param("memberId") Long memberId
    );
}
