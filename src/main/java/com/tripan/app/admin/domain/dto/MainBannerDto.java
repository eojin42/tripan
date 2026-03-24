package com.tripan.app.admin.domain.dto;

import java.util.Date;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class MainBannerDto {
	private int    bannerId;
    private String bannerName;
    private String imageUrl;
    private String eyebrowText;
    private String mainTitle;
    private String subTitle;
    private int    sortOrder;
    private String isVisible;
    private Date   regDate;
    private Date   modDate;
}