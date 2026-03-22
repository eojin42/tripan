package com.tripan.app.admin.service;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.tripan.app.admin.domain.dto.PointManageDto;
import com.tripan.app.admin.mapper.PointManageMapper;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
@RequiredArgsConstructor
public class PointManageServiceImpl implements PointManageService{

	private final PointManageMapper pointManageMapper;
	 
    /* ── 회원별 포인트 요약 목록 ── */
    @Override
    @Transactional(readOnly = true)
    public List<PointManageDto> getMemberPointList(PointManageDto.SearchRequest request) {
        return pointManageMapper.selectMemberPointList(
                request.getKeyword(),
                request.getStartDate(),
                request.getEndDate()
        );
    }
 
    /* ── 개인 포인트 내역 ── */
    @Override
    @Transactional(readOnly = true)
    public List<PointManageDto.HistoryDto> getPointHistory(Long memberId,
                                                            String startDate,
                                                            String endDate) {
        return pointManageMapper.selectPointHistory(memberId, startDate, endDate);
    }
 
    /* ── 포인트 지급/차감 (개인 or 일괄) ── */
    @Override
    @Transactional
    public void adjustPoints(PointManageDto.AdjustRequest request) {
        if (request.getMemberIds() == null || request.getMemberIds().isEmpty()) {
            throw new IllegalArgumentException("대상 회원을 선택해주세요.");
        }
        if (request.getPointAmount() == 0) {
            throw new IllegalArgumentException("포인트는 0이 될 수 없습니다.");
        }
        if (request.getChangeReason() == null || request.getChangeReason().isBlank()) {
            throw new IllegalArgumentException("지급 사유를 입력해주세요.");
        }
 
        for (Long memberId : request.getMemberIds()) {
            /* 현재 잔여 포인트 조회 */
        	Integer currentRem = pointManageMapper.selectRemPoint(memberId);
        	int rem = (currentRem != null) ? currentRem : 0;  // null이면 0으로
        	int newRem = rem + request.getPointAmount();
 
            /* 차감 시 잔액 부족 체크 */
            if (newRem < 0) {
                log.warn("[Point] 잔액 부족으로 차감 스킵: memberId={}, current={}, amount={}",
                        memberId, currentRem, request.getPointAmount());
                continue;
            }
 
            pointManageMapper.insertPointHistory(
                    memberId,
                    null,
                    request.getChangeReason(),
                    request.getPointAmount(),
                    newRem
            );
 
            log.info("[Point] 포인트 조정: memberId={}, amount={}, remPoint={}",
                    memberId, request.getPointAmount(), newRem);
        }
    }

}
