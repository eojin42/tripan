package com.tripan.app.domain.dto;

import java.util.Date;
import lombok.Data;

@Data
public class PlaceDto {
    private Long placeId;
    private Long partnerId;
    private String placeName;
    private String category;
    private String address;
    private Double latitude;
    private Double longitude;
    private String phoneNumber;
    private String description;
    private String imageUrl;
    private Date modifiedtime;
    private Date createdtime;
}