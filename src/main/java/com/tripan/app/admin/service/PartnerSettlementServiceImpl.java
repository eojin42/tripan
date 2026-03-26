package com.tripan.app.admin.service;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.tripan.app.admin.domain.dto.SettlementAggregateDto;
import com.tripan.app.admin.domain.dto.SettlementFilterDto;
import com.tripan.app.admin.domain.dto.SettlementManageDto;
import com.tripan.app.admin.domain.dto.SettlementOrderDto;
import com.tripan.app.admin.mapper.PartnerSettlementMapper;
import com.tripan.app.admin.mapper.SettlementBatchMapper;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class PartnerSettlementServiceImpl implements PartnerSettlementService {

    private final PartnerSettlementMapper settlementMapper;
    private final SettlementBatchMapper   batchMapper;

    // ─────────────────────────────────────────
    //  조회
    // ─────────────────────────────────────────

    @Override
    public List<SettlementManageDto> getSummaryList(SettlementFilterDto filter) {
        return settlementMapper.selectSummaryList(filter);
    }

    @Override
    public int getSummaryCount(SettlementFilterDto filter) {
        return settlementMapper.selectSummaryCount(filter);
    }

    @Override
    public List<SettlementManageDto> getDetailList(SettlementFilterDto filter) {
        // selectDetailList는 이제 memberId 기준으로 파트너(숙소) 목록 반환
        List<SettlementManageDto> details = settlementMapper.selectDetailList(filter);
        for (SettlementManageDto d : details) {
            Map<String, Object> params = new HashMap<>();
            // detail의 각 행은 partner_id 단위 → partnerId 사용
            params.put("partnerId",       d.getPartnerId());
            params.put("settlementMonth", filter.getSettlementMonth());
            List<SettlementOrderDto> orders = settlementMapper.selectOrderLines(params);
            d.setOrders(orders);
        }
        return details;
    }

    @Override
    public List<SettlementOrderDto> getExcelRowsByPartner(SettlementFilterDto filter) {
        return settlementMapper.selectExcelByPartner(filter);
    }

    @Override
    public List<SettlementOrderDto> getExcelRowsByPlace(SettlementFilterDto filter) {
        return settlementMapper.selectExcelByPlace(filter);
    }

    // ─────────────────────────────────────────
    //  정산 승인 — 개별 파트너(숙소) 1개 승인
    // ─────────────────────────────────────────

    @Override
    @Transactional
    public void approvePlace(Long partnerId, String settlementMonth, Long adminId) {
        Map<String, Object> params = new HashMap<>();
        params.put("partnerId",       partnerId);
        params.put("settlementMonth", settlementMonth);
        settlementMapper.upsertSettlement(params);
        log.info("[정산 승인] partnerId={}, month={}, adminId={}", partnerId, settlementMonth, adminId);
    }

    // ─────────────────────────────────────────
    //  정산 승인 — 멤버 소속 파트너 전체 승인
    //  memberId 소속 파트너 ID 전체를 조회한 뒤
    //  각 partnerId 별로 upsertSettlement 호출
    //  → partial 상태에서도 미승인 파트너만 순회하며 done 처리
    // ─────────────────────────────────────────

    @Override
    @Transactional
    public void approveAllByPartner(Long memberId, String settlementMonth, Long adminId) {
        Map<String, Object> params = new HashMap<>();
        params.put("memberId", memberId);

        // 소속 파트너 ID 전체 조회
        List<Long> partnerIds = settlementMapper.selectPartnerIdsByMember(params);

        if (partnerIds == null || partnerIds.isEmpty()) {
            log.warn("[전체 정산 승인] 소속 파트너 없음 - memberId={}", memberId);
            return;
        }

        log.info("[전체 정산 승인] memberId={}, 파트너 수={}, month={}", memberId, partnerIds.size(), settlementMonth);

        for (Long partnerId : partnerIds) {
            approvePlace(partnerId, settlementMonth, adminId);
        }

        log.info("[전체 정산 승인] 완료 - memberId={}, month={}", memberId, settlementMonth);
    }

    // ─────────────────────────────────────────
    //  배치 정산 집계
    // ─────────────────────────────────────────

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void aggregateSettlement() {
        String targetMonth = LocalDate.now()
                .format(DateTimeFormatter.ofPattern("yyyy-MM"));

        log.info("[정산 배치] 시작 - 집계 대상 월: {}", targetMonth);

        List<SettlementAggregateDto> targets = batchMapper.selectUnsettledAggregates(targetMonth);

        if (targets.isEmpty()) {
            log.info("[정산 배치] 대상 없음 - 종료");
            return;
        }

        log.info("[정산 배치] 집계 대상: {}건", targets.size());

        int successCount = 0;
        int skipCount    = 0;

        for (SettlementAggregateDto dto : targets) {
            try {
                boolean exists = batchMapper.existsSettlement(
                        dto.getPartnerId(), dto.getSettlementMonth());

                if (exists) {
                    batchMapper.updateSettlementAmount(dto);
                    log.debug("[정산 배치] UPDATE - partnerId={}, month={}",
                            dto.getPartnerId(), dto.getSettlementMonth());
                } else {
                    batchMapper.insertSettlement(dto);
                    log.debug("[정산 배치] INSERT - partnerId={}, month={}",
                            dto.getPartnerId(), dto.getSettlementMonth());
                }
                successCount++;

            } catch (Exception e) {
                skipCount++;
                log.error("[정산 배치] 처리 실패 - partnerId={}, month={}, 오류={}",
                        dto.getPartnerId(), dto.getSettlementMonth(), e.getMessage());
            }
        }

        log.info("[정산 배치] 완료 - 성공: {}건, 실패/스킵: {}건", successCount, skipCount);
    }
    
    public List<String> getAvailableMonths() {
        return settlementMapper.selectAvailableMonths();
    }
}