package com.tripan.app.admin.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.tripan.app.admin.domain.dto.CouponTargetDto;
import com.tripan.app.domain.dto.AccommodationDto;
import com.tripan.app.domain.dto.RoomDto;

@Mapper
public interface CouponTargetMapper {
	void insertCouponTarget(CouponTargetDto dto);

    List<CouponTargetDto> selectCouponTargets(@Param("couponId") Long couponId);

    void deleteCouponTargets(@Param("couponId") Long couponId);

    List<AccommodationDto> searchAccommodations(Map<String, Object> params);

    List<String> selectAccTypeOptions();

    List<RoomDto> selectRoomsByAccommodation(@Param("placeId") Long placeId, @Param("keyword") String keyword);

    int isCouponApplicable(@Param("couponId") Long couponId,
                           @Param("placeId") Long placeId,
                           @Param("roomId") Long roomId,
                           @Param("accommodationType") String accommodationType);
}
