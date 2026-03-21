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
public class PartnerSettlementServiceImpl implements PartnerSettlementService{

    private final PartnerSettlementMapper settlementMapper;
    private final SettlementBatchMapper   batchMapper; 

    // ─────────────────────────────────────────
    //  조회
    // ─────────────────────────────────────────

    public List<SettlementManageDto> getSummaryList(SettlementFilterDto filter) {
        return settlementMapper.selectSummaryList(filter);
    }

    public int getSummaryCount(SettlementFilterDto filter) {
        return settlementMapper.selectSummaryCount(filter);
    }

    public List<SettlementManageDto> getDetailList(SettlementFilterDto filter) {
        List<SettlementManageDto> details = settlementMapper.selectDetailList(filter);
        for (SettlementManageDto d : details) {
            List<SettlementOrderDto> orders = settlementMapper.selectOrderLines(
                    d.getPlaceId(), filter.getSettlementMonth());
            d.setOrders(orders);
        }
        return details;
    }

    /** 엑셀용 예약 건 목록 — 파트너 전체 숙소 */
    public List<SettlementOrderDto> getExcelRowsByPartner(SettlementFilterDto filter) {
        return settlementMapper.selectExcelByPartner(filter);
    }

    /** 엑셀용 예약 건 목록 — 숙소 단위 */
    public List<SettlementOrderDto> getExcelRowsByPlace(SettlementFilterDto filter) {
        return settlementMapper.selectExcelByPlace(filter);
    }

    // ─────────────────────────────────────────
    //  정산 승인
    // ─────────────────────────────────────────

    @Transactional
    public void approvePlace(Long placeId, String settlementMonth, Long adminId) {
        Map<String, Object> params = new HashMap<>();
        params.put("placeId", placeId);
        params.put("settlementMonth", settlementMonth);
        params.put("adminId", adminId);
        settlementMapper.upsertSettlement(params);
    }

    @Transactional
    public void approveAllByPartner(Long memberId, String settlementMonth, Long adminId) {
        SettlementFilterDto filter = new SettlementFilterDto();
        filter.setMemberId(memberId);
        filter.setSettlementMonth(settlementMonth);
        List<SettlementManageDto> details = settlementMapper.selectDetailList(filter);
        for (SettlementManageDto d : details) {
            if (!"APPROVED".equals(d.getSettlementStatus())) {
                approvePlace(d.getPlaceId(), settlementMonth, adminId);
            }
        }
    }

    @Transactional(rollbackFor = Exception.class)
    public void aggregateSettlement() {
        String targetDate = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
        log.info("[정산 배치] 시작 - 기준일: {}", targetDate);
 
        List<SettlementAggregateDto> targets = batchMapper.selectUnsettledAggregates(targetDate);
 
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
 
        log.info("[정산 배치] 완료 - 성공: {}건, 실패: {}건", successCount, skipCount);
    }
    
   
}
