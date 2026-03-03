package com.tripan.app.domain.trip.entity;

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
@Table(name = "itinerary_image")
@Getter @Setter
public class ItineraryImage {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "image_id")
    private Long imageId; 

    @Column(name = "item_id", nullable = false)
    private Long itemId; // 어떤 일정 항목의 이미지인지 (FK)

    @Column(name = "member_id", nullable = false)
    private Long memberId; // 올린 사람

    @Column(name = "image_url", nullable = false, length = 500)
    private String imageUrl; // 이미지 url 

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now(); 
}