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
    private String contactName;      
    private String contactPhone;     
    private String contactEmail;     
    private String expStatus;        
    
    // 숙소 기본 정보
    private String partnerName;      
    private String address;          
    private String homepageUrl;      
    private String partnerIntro;     

    // 사업자 및 정산 정보
    private String bizStatus;        
    private String businessNumber;   
    private String accommodationType;
    private String bankName;         
    private String accountNumber;    

    // 파일 및 시스템 정보
    private List<MultipartFile> bizLicenseFiles; 
    private Long partnerId;          
    private Long memberId;           
    private String status;           
    private String contractfileUrl;  
    private String logoImageUrl;     
    private Date createdAt;          
    private String rejectReason;    

    // 연관 테이블 생성을 위한 PK 조각 
    private Long placeId;            
}