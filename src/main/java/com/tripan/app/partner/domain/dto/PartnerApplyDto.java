package com.tripan.app.partner.domain.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.web.multipart.MultipartFile;

import java.util.Date;

/**
 * 파트너 입점 신청 처리를 위한 DTO
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PartnerApplyDto {

    // 1. 담당자 정보
    private String contactName;      // 담당자 성함 
    private String contactPhone;     // 담당자 전화번호 
    private String email;            // 담당자 이메일 (승인 알림용)
    private String expStatus;        // 숙박업 경험 유무 (경험 없음 / 경험 있음)

    // 2. 스테이(숙소) 정보
    private String partnerName;      // 스테이 이름 
    private String address;          // 스테이 주소
    private String homepageUrl;      // 웹사이트 및 SNS 주소
    private String partnerIntro;     // 스테이 소개 (최소 50자)

    // 3. 사업자 정보
    private String bizStatus;        // 사업자 등록 여부 (준비 중 / 등록 완료)
    private String businessNumber;   // 사업자 번호 
    private String accommodationType; // 업종 (펜션, 호텔 등)

    // 4. 파일 업로드 (Multipart 객체)
    private MultipartFile bizLicenseFile; // 사업자 등록증 파일
    private MultipartFile representativeImg; // 대표 이미지 파일

    // 5. 시스템 내부용 (DB 컬럼 매칭)
    private Long partnerId;          // PK
    private String status;           // 상태 (기본값: PENDING) 
    private String contractfileUrl;  // 서버에 저장된 PDF 경로
    private String logoImageUrl;     // 서버에 저장된 이미지 경로
    private Date createdAt;          // 신청 일시
}