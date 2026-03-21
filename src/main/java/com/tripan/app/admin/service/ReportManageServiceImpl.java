package com.tripan.app.admin.service;

import com.tripan.app.admin.domain.dto.ReportManageDto;
import com.tripan.app.admin.mapper.ReportManageMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class ReportManageServiceImpl implements ReportManageService {

    private final ReportManageMapper reportManageMapper;

    private static final int HIDE_THRESHOLD = 5;
    private static final int BAN_THRESHOLD  = 10;

    @Override
    public List<ReportManageDto> getContentList(String targetType) {
        return reportManageMapper.selectContentList(targetType);
    }

    @Override
    public List<ReportManageDto> getUserReportList() {
        return reportManageMapper.selectUserReportList();
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void processAfterReport(String targetType, Long targetId) {
        int contentCount = reportManageMapper.countReportsByTarget(targetType, targetId);
        log.info("[신고 자동처리] targetType={} targetId={} 신고수={}", targetType, targetId, contentCount);

        if (contentCount >= HIDE_THRESHOLD) {
            hideContent(targetType, targetId);
            reportManageMapper.updateReportStatus(targetType, targetId);
            log.info("[신고 자동처리] 콘텐츠 숨김 - targetType={} targetId={}", targetType, targetId);
        }

        Long ownerId = reportManageMapper.selectContentOwnerId(targetType, targetId);
        if (ownerId == null) return;

        int userCount = reportManageMapper.countReportsByReportedUser(ownerId);
        log.info("[신고 자동처리] memberId={} 누적 신고수={}", ownerId, userCount);

        if (userCount >= BAN_THRESHOLD) {
            reportManageMapper.banMember(ownerId);
            reportManageMapper.insertBanStatus(ownerId, "신고 누적 " + userCount + "회로 자동 정지");
            log.info("[신고 자동처리] 유저 정지 - memberId={}", ownerId);
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deactivateContent(String targetType, Long targetId) {
        hideContent(targetType, targetId);
        reportManageMapper.updateReportStatus(targetType, targetId);
        log.info("[어드민 비활성화] targetType={} targetId={}", targetType, targetId);
    }

    private void hideContent(String targetType, Long targetId) {
        switch (targetType) {
            case "FEED"              -> reportManageMapper.hideFeedPost(targetId);
            case "FEED_COMMENT"      -> reportManageMapper.hidePostComment(targetId);
            case "FREEBOARD"         -> reportManageMapper.hideFreeboard(targetId);
            case "FREEBOARD_COMMENT" -> reportManageMapper.hideFreeboardComment(targetId);
            case "MATE"              -> reportManageMapper.hideTravelMate(targetId);
            case "MATE_COMMENT"      -> reportManageMapper.hideTravelMateComment(targetId);
            default -> log.warn("[숨김처리] 알 수 없는 targetType={}", targetType);
        }
    }
}