package com.tripan.app.domain.dto;

import java.util.Date;

import lombok.Data;

@Data
public class FestivalImageDto {
    private Long imageId;          // PK
    private Long festivalId;       // FK
    private String originImgUrl;
    private String smallImgUrl;
    private String imgName;
    private Date createAt;
}