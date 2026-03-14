package com.tripan.app.trip.repository;

import com.tripan.app.trip.domain.entity.TripPlace;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;
import java.util.List;

@Repository
public interface TripPlaceRepository extends JpaRepository<TripPlace, Long> {

    /**
     * api_place_id (카카오/KTO 고유 ID) 로 TripPlace 조회
     * ItineraryServiceImpl.addPlaceAndItinerary() 에서 중복 체크에 사용
     */
    Optional<TripPlace> findByApiPlaceId(String apiPlaceId);

    /**
     * 특정 회원의 나만의 장소 목록
     */
    List<TripPlace> findByMemberId(Long memberId);

    /**
     * 공용(member_id IS NULL) + 해당 회원 장소 검색
     */
    List<TripPlace> findByMemberIdIsNullOrMemberId(Long memberId);
}
