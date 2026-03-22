package com.tripan.app.admin.service;

import java.util.List;

import com.tripan.app.admin.domain.dto.ReportManageDto;

public interface ReportManageService {
	
	/** 콘텐츠 단위 집계 목록 */
    List<ReportManageDto> getContentList(String targetType);
 
    /** 이용자별 신고 목록 */
    List<ReportManageDto> getUserReportList();
 
    /** 신고 접수 후 자동 처리 (5번→숨김, 10번→정지) */
    void processAfterReport(String targetType, Long targetId);
 
    /** 콘텐츠 비활성화 (어드민 수동) */
    void deactivateContent(String targetType, Long targetId);
    
    void activateContent(String targetType, Long targetId);
}
