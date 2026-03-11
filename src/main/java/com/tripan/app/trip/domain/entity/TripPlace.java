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
	private Long tripPlaceId; // 유저 장소 ID
	
	@Column(name = "member_id", nullable = false)
    private Long memberId; // 방장(생성자) ID
	
	@Column(name = "api_place_id", unique = true, length = 100)
	private String apiPlaceId; // 카카오/네이버 지도의 고유 장소 ID
	
	@Column(name = "place_name", nullable = false, length = 200)
	private String placeName; // 장소명
	
	@Column(name = "address", length = 500)
	private String address; // 지번 또는 도로명 주소 
	
	@Column(name = "latitude", nullable = false)
	private Double latitude; // 위도 
	
	@Column(name = "longitude", nullable = false)
	private Double longitude; // 경도
	
	@Column(name = "category_name" , length = 100)
	private String categoryName; // 카테고리(숙소/식당/관광지 등)
	
	@Column(name = "place_url" , length = 1000)
	private String placeUrl; // 지도 상세 웹페이지 링크
	
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now(); // 추가일시 
}
