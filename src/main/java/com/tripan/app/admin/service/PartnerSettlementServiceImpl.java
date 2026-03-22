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
        List<SettlementManageDto> details = settlementMapper.selectDetailList(filter);
        for (SettlementManageDto d : details) {
            // selectOrderLines는 partnerId 기준 — d.getMemberId() = partner_id
            Map<String, Object> params = new HashMap<>();
            params.put("partnerId",       d.getMemberId());
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
    //  정산 승인 (수동 — 관리자)
    //  ※ partner_settlement는 partner_id 단위이므로
    //    placeId 파라미터명을 유지하되 내부에서 partnerId로 사용
    // ─────────────────────────────────────────

    @Override
    @Transactional
    public void approvePlace(Long partnerId, String settlementMonth, Long adminId) {
        Map<String, Object> params = new HashMap<>();
        params.put("partnerId",       partnerId);
        params.put("settlementMonth", settlementMonth);
        settlementMapper.upsertSettlement(params);
    }

    @Override
    @Transactional
    public void approveAllByPartner(Long memberId, String settlementMonth, Long adminId) {
        SettlementFilterDto filter = new SettlementFilterDto();
        filter.setMemberId(memberId);
        filter.setSettlementMonth(settlementMonth);

        List<SettlementManageDto> details = settlementMapper.selectDetailList(filter);

        // ERD status: 'done' / 'wait'
        boolean hasUnapproved = details.stream()
                .anyMatch(d -> !"done".equals(d.getSettlementStatus()));

        if (hasUnapproved) {
            // partner_settlement는 파트너 단위이므로 1회 upsert
            approvePlace(memberId, settlementMonth, adminId);
        }
    }

    // ─────────────────────────────────────────
    //  배치 정산 집계 (매일 새벽 2시 — AdminScheduler 호출)
    //  SettlementBatchMapper를 통해 partner_settlement INSERT/UPDATE
    // ─────────────────────────────────────────

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void aggregateSettlement() {
        // ※ 운영 시: .minusMonths(1) 로 전월 기준 집계
        // ※ 테스트 시: 현재 월 체크아웃 포함 집계 (아래가 테스트 모드)
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
                    // 레코드가 이미 있으면 금액 누적 UPDATE
                    // (수동 승인으로 'done'이 된 경우도 금액은 최신화)
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
}