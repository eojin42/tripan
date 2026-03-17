package com.tripan.app.partner.domain.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PartnerFileDto {
    private Long fileId;           // 파일 PK
    private Long partnerId;        // 부모 파트너 PK (FK)
    private String originFileName; // 원본 파일명 (예: 사업자등록증.pdf)
    private String fileUrl;        // 저장된 실제/웹 경로
    private String fileType;       // 파일 확장자 또는 MIME 타입
}