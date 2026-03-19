package com.tripan.app.partner.domain.dto;

import lombok.Data;

@Data
public class PartnerInfoDto {
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
}