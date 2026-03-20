package com.tripan.app.partner.domain.dto;

import org.springframework.web.multipart.MultipartFile;
import lombok.Data;

@Data
public class PartnerInfoDto {
    // Partner 정보
    private Long partnerId;
    private Long memberId;
    private String partnerName;
    private String businessNumber;
    private String contactName;
    private String contactPhone;
    private String bankName;
    private String accountNumber;
    private String partnerIntro;
    private String status;
    private String accommodationType;
    
    private Long placeId;
    private String address;
    private Double latitude;
    private Double longitude;
    private String imageUrl; 
    
    private MultipartFile uploadImage; 
}