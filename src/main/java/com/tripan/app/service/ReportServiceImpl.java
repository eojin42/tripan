package com.tripan.app.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.tripan.app.domain.dto.ReportDto;
import com.tripan.app.mapper.CommunityFreeBoardMapper;
import com.tripan.app.mapper.CommunityMateMapper;          
import com.tripan.app.mapper.CommunityMateCommentMapper;  
import com.tripan.app.mapper.ReportMapper;

// 🚨 1. 관리자용 매퍼 임포트 추가!
import com.tripan.app.admin.mapper.MemberManageMapper; 

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ReportServiceImpl implements ReportService {

    private final ReportMapper reportMapper;
    private final CommunityFreeBoardMapper freeboardMapper;
    
    private final CommunityMateMapper mateMapper;
    private final CommunityMateCommentMapper mateCommentMapper;

    private final MemberManageMapper memberManageMapper; 

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
            switch (reportDto.getTargetType()) {
                case "FREEBOARD": // 자유게시판 글
                    freeboardMapper.updateStatus(reportDto.getTargetId(), 0); 
                    break;
                    
                case "COMMENT": // 자유게시판 댓글
                    freeboardMapper.updateCommentStatus(reportDto.getTargetId(), 0); 
                    break;
                    
                case "MATE": //  동행 모집 글
                    mateMapper.updateMateBlindStatus(reportDto.getTargetId(), 0);
                    break;
                    
                case "MATE_COMMENT": //  동행 모집 댓글
                    mateCommentMapper.updateCommentBlindStatus(reportDto.getTargetId(), 0);
                    break;
                    
                /* 피드(Feed) 게시판 작업필요
                case "FEED": 
                    feedMapper.updateStatus(reportDto.getTargetId(), 0);
                    break;
                case "FEED_COMMENT": 
                    feedCommentMapper.updateCommentBlindStatus(reportDto.getTargetId(), 0);
                    break;
                */
            }
        }

        int memberReportCount = reportMapper.countReportByReportedId(reportDto.getReportedId());

        if (memberReportCount >= 10) {
            memberManageMapper.updateMember1Status(reportDto.getReportedId(), 2);
            
            memberManageMapper.insertMemberStatusHistory(
                reportDto.getReportedId(), 
                2, 
                "🚨 누적 신고 10회 초과로 인한 시스템 자동 이용 정지"
            );
            
            System.out.println("🚨 10회 누적! 회원 번호 [" + reportDto.getReportedId() + "] 정지 및 이력 저장 완료!");
        }
    }
}