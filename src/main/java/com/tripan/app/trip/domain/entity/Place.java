package com.tripan.app.trip.domain.entity;

import jakarta.persistence.*;
import lombok.Getter;

import java.time.LocalDateTime;

@Entity
@Table(name = "place") 
@Inheritance(strategy = InheritanceType.JOINED) 
@Getter
public class Place {

    @Id
    @Column(name = "place_id")
    private Long placeId; // KTO contentid

    @Column(name = "partner_id")
    private Long partnerId;

    @Column(name = "place_name", nullable = false)
    private String placeName;

    private String category;
    private String address;
    private Double latitude;
    private Double longitude;
    
    @Column(name = "phone_number")
    private String phoneNumber;
    
    private String description;
    
    @Column(name = "image_url")
    private String imageUrl;

    @Column(name = "created_at")
    private LocalDateTime createdAt;
    

}