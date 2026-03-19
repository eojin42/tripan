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

    private String contactName;       // 담당자 성함 
    private String contactPhone;     // 담당자 전화번호 
    private String contactEmail;     // 담당자 이메일 (생략 -> null)
    private String expStatus;        // 숙박업 경험 유무 (생략 -> null)
    

    private String partnerName;      // 스테이 이름 (JSP 매칭 됨)
    private String address;          // 스테이 주소 (생략 -> null)
    private String homepageUrl;      // 웹사이트 및 SNS 주소 (생략 -> null)
    private String partnerIntro;     // 스테이 소개 (JSP 매칭 됨)

    private String bizStatus;        // 사업자 등록 여부 (생략 -> null)
    private String businessNumber;   // 사업자 번호 (생략 -> null)
    private String accommodationType;// 업종 (생략 -> null)

    private List<MultipartFile> bizLicenseFiles; 

    private Long partnerId;          // PK
    private Long memberId;           // 로그인한 회원의 PK 
    private String status;           // 상태 (기본값: PENDING) 
    private String contractfileUrl;  // (대표 PDF 경로용으로 사용 가능)
    private String logoImageUrl;     // (대표 이미지 경로용으로 사용 가능)
    private Date createdAt;          // 신청 일시
    
    private String rejectReason;
}