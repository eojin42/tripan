package com.tripan.app.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.tripan.app.domain.dto.ReportDto;
import com.tripan.app.mapper.CommunityFreeBoardMapper;
import com.tripan.app.mapper.ReportMapper;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ReportServiceImpl implements ReportService {

    private final ReportMapper reportMapper;
    private final CommunityFreeBoardMapper freeboardMapper;
    // private final MemberManageMapper memberManageMapper; 

    @Override
    @Transactional 
    public void submitReport(ReportDto reportDto) {
        
        int isDuplicate = reportMapper.checkDuplicateReport(reportDto);
        if (isDuplicate > 0) {
            throw new IllegalArgumentException("이미 신고가 접수된 항목입니다.");
        }

        reportMapper.insertReport(reportDto);

        int targetReportCount = reportMapper.countReportByTarget(reportDto.getTargetType(), reportDto.getTargetId());
        
        if (targetReportCount >= 5) {
            if ("FREEBOARD".equals(reportDto.getTargetType())) {
                freeboardMapper.updateStatus(reportDto.getTargetId(), 0); 
            } else if ("COMMENT".equals(reportDto.getTargetType())) {
                freeboardMapper.updateCommentStatus(reportDto.getTargetId(), 0); 
            }
        }

        int memberReportCount = reportMapper.countReportByReportedId(reportDto.getReportedId());

        if (memberReportCount >= 10) {
            System.out.println("🚨 경고: 회원 번호 [" + reportDto.getReportedId() + "] 님이 누적 신고 10회로 커뮤니티 이용이 정지되어야 합니다.");
        }
    }
}