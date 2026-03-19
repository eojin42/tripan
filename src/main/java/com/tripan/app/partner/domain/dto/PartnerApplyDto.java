package com.tripan.app.partner.domain.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.web.multipart.MultipartFile;

import java.util.Date;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PartnerApplyDto {

    // 담당자 정보
    private String contactName;       // 담당자 성함 
    private String contactPhone;     // 담당자 전화번호 
    private String contactEmail;     // 담당자 이메일
    private String expStatus;        // 숙박업 경험 유무 (Y/N)
    
    // 숙소 기본 정보
    private String partnerName;      // 숙소 이름 (PARTNER & PLACE 테이블 공용)
    private String address;          // 숙소 주소 (초기 신청 시 NULL 가능)
    private String homepageUrl;      // 웹사이트 및 SNS 주소
    private String partnerIntro;     // 숙소 소개글

    // 사업자 정보
    private String bizStatus;        // 사업자 등록 여부
    private String businessNumber;   // 사업자 등록 번호
    private String accommodationType;// 업종 (호텔, 펜션 등)

    // 파일 및 시스템 정보
    private List<MultipartFile> bizLicenseFiles; // 증빙 서류 파일 리스트
    private Long partnerId;          // PARTNER 테이블 PK
    private Long memberId;           // 신청한 회원의 PK
    private String status;           // 신청 상태 (기본값: PENDING) 
    private String contractfileUrl;  // 전자 계약서 경로
    private String logoImageUrl;     // 숙소 로고/대표 이미지 경로
    private Date createdAt;          // 신청 일시
    private String rejectReason;     // 심사 반려 사유

    // 연관 테이블 생성을 위한 조각 
    private Long placeId;            //  PLACE 생성 후 발급받을 PK 
    private Long afId;               // ACCOMMODATION_FACILITY 생성 후 발급받을 PK 
}