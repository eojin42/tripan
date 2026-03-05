package com.tripan.app.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.tripan.app.trip.domian.entity.TripMember;

@Mapper
public interface TripMemberMapper {


    // 여행 ID와 멤버 ID로 특정 동행자 정보 조회
    TripMember findByTripIdAndMemberId(@Param("tripId") Long tripId, @Param("memberId") Long memberId);

}