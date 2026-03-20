package com.tripan.app.admin.service;

import com.tripan.app.admin.domain.dto.SettlementFilterDto;
import com.tripan.app.admin.domain.dto.SettlementManageDto;
import com.tripan.app.admin.domain.dto.SettlementOrderDto;
import com.tripan.app.admin.mapper.SettlementManageMapper;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class SettlementManageServiceImpl implements SettlementManageService{

    private final SettlementManageMapper settlementMapper;

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
}
