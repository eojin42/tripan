package com.tripan.app.trip.domain.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "trip_region")
@Getter @Setter
public class TripRegion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "trip_region_id")
    private Long tripRegionId;

    @Column(name = "trip_id")
    private Long tripId;

    @Column(name = "region_id")
    private Long regionId;

    
}