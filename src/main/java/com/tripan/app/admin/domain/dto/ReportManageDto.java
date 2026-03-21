package com.tripan.app.admin.domain.dto;

import java.util.List;

import lombok.Getter;
import lombok.Setter;
 
@Getter
@Setter
public class ReportManageDto {
 
    private Long          reportId;
    private Long          reporterId;
    private String        reporterNickname;
 
    private String        targetType;   // FEED / FEED_COMMENT / FREEBOARD / FREEBOARD_COMMENT / MATE / MATE_COMMENT
    private Long          targetId;
    private String        targetContent; // 신고된 콘텐츠 내용 (미리보기)
    private int    		  contentStatus; // 1=활성, 0=비활성(숨김)
 
    private Long          reportedMemberId;    // 콘텐츠 작성자
    private String        reportedNickname;
 
    private String        reason;
    private String        status;        // PENDING / PROCESSED
    private String createdAt;
 
    private int           totalReportCount;    // 해당 콘텐츠 누적 신고 수
    private int           userReportCount;     // 해당 유저 누적 신고 수 (복구 이후)
    private String latestReportAt; 
    private List<ReportManageDto> reports;
    
}