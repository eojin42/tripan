package com.tripan.app.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import com.tripan.app.domain.dto.PlaceDto;

@Mapper
public interface PlaceMapper {
    Long findPlaceIdByNameAndAddress(@Param("placeName") String placeName, @Param("address") String address);
    int insertPlace(PlaceDto place);
}