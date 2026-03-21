package com.tripan.app.domain.dto;

import lombok.Data;

@Data
public class ReportDto {
    private Long reportId;
    private Long reporterId;   // 신고자 
    private Long reportedId;   // 신고 당한 사람 (타겟이 된 회원 번호)
    private String targetType; // 신고 대상 종류 
    private Long targetId;     // 신고 대상 글/댓글 번호
    private String reason;     // 신고 사유
    private String status;     // 처리 상태 
    private String createdAt;
    
}