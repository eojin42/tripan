package com.tripan.app.trip.domain.entity;

import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "trip_place")
@Getter @Setter
public class TripPlace {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "trip_place_id")
    private Long tripPlaceId;

    @Column(name = "member_id", nullable = true)
    private Long memberId;

    /**
     * 카카오/KTO API 고유 ID (UNIQUE)
     * - 카카오 검색: 카카오 place_id (숫자 문자열)
     * - KTO 공식:   contentid (숫자)
     * - 나만의 장소: "custom_" + timestamp
     */
    @Column(name = "api_place_id", unique = true, length = 100)
    private String apiPlaceId;

    @Column(name = "place_name", nullable = false, length = 200)
    private String placeName;

    @Column(name = "address", length = 500)
    private String address;

    @Column(name = "latitude", nullable = false)
    private Double latitude;

    @Column(name = "longitude", nullable = false)
    private Double longitude;

    /**
     * 카테고리 (PlaceServiceImpl의 mapContentTypeToCategory 결과)
     * TOUR / ACCOMMODATION / RESTAURANT / CULTURE / LEISURE / SHOPPING / ETC
     */
    @Column(name = "category_name", length = 100)
    private String categoryName;

    @Column(name = "place_url", length = 1000)
    private String placeUrl;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now();
}
