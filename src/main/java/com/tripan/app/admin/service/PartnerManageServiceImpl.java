package com.tripan.app.admin.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.tripan.app.admin.domain.dto.PartnerKpiDto;
import com.tripan.app.admin.domain.dto.PartnerManageDto;
import com.tripan.app.admin.mapper.PartnerManageMapper;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class PartnerManageServiceImpl implements PartnerManageService {

    private final PartnerManageMapper partnerMapper;

    // ── Map → PartnerManageDto 변환 ──────────────────────────
    private PartnerManageDto toDto(Map<String, Object> row) {
        Object pid     = row.getOrDefault("partnerId",  row.getOrDefault("PARTNERID",  null));
        String status  = String.valueOf(row.getOrDefault("status",      row.getOrDefault("STATUS",      "")));
        Object commRaw = row.getOrDefault("commissionRate", row.getOrDefault("COMMISSIONRATE", null));

        java.math.BigDecimal commRate = java.math.BigDecimal.ZERO;
        if (commRaw != null) {
            try { commRate = new java.math.BigDecimal(commRaw.toString()); } catch (Exception ignored) {}
        }

        String statusLabel = switch (status.toUpperCase()) {
            case "PENDING"   -> "승인대기";
            case "ACTIVE"    -> "정상";
            case "REJECTED"  -> "반려";
            case "SUSPENDED" -> "이용정지";
            case "BLOCKED"   -> "영구차단";
            default          -> status;
        };
        
        String accType = strNull(row, "accommodationType", "ACCOMMODATION_TYPE");
        
        String categoryLabel = "-";
        if (accType != null) {
            categoryLabel = switch (accType.toUpperCase()) {
                case "HOTEL"      -> "호텔/리조트";
                case "MOTEL"      -> "모텔";
                case "PENSION"    -> "펜션/풀빌라";
                case "GUESTHOUSE" -> "게스트하우스/한옥";
                default           -> accType;
            };
        }

        Long partnerIdVal = pid != null ? Long.valueOf(pid.toString()) : null;

        Object createdAtRaw = row.getOrDefault("createdAt", row.getOrDefault("CREATEDAT", null));

        return PartnerManageDto.builder()
            .partnerId(partnerIdVal)
            .applyId(partnerIdVal)   // apply 화면에서 applyId로 심사 처리 시 사용
            .partnerName(str(row, "partnerName",     "PARTNERNAME",     "-"))
            .businessNumber(str(row, "businessNumber", "BUSINESSNUMBER",  "-"))
            .contactName(str(row, "contactName",     "CONTACTNAME",     "-"))
            .contactPhone(str(row, "contactPhone",    "CONTACTPHONE",    "-"))
            .rejectReason(strNull(row, "rejectReason",   "REJECTREASON"))
            .createdAt(createdAtRaw instanceof java.util.Date ? (java.util.Date) createdAtRaw : null)
            .status(status)
            .statusLabel(statusLabel)
            .commissionRate(commRate)
            .accommodationType(accType)
            .build();
    }

    private String str(Map<String, Object> row, String k1, String k2, String def) {
        Object v = row.getOrDefault(k1, row.getOrDefault(k2, null));
        return v != null ? v.toString() : def;
    }

    private String strNull(Map<String, Object> row, String k1, String k2) {
        Object v = row.getOrDefault(k1, row.getOrDefault(k2, null));
        return v != null ? v.toString() : null;
    }

    // ── 조회 ────────────────────────────────────────────────
    @Override
    public List<PartnerManageDto> getAllPartners() {
        return partnerMapper.selectAllPartners().stream()
            .map(row -> toDto(row))
            .collect(Collectors.toList());
    }

    @Override
    public List<PartnerManageDto> getActivePartners() {
        return partnerMapper.selectActivePartners().stream()
            .map(row -> toDto(row))
            .collect(Collectors.toList());
    }

    @Override
    public PartnerKpiDto getKpi() {
        List<Map<String, Object>> all = partnerMapper.selectAllPartners();
        int pending = 0, active = 0, suspended = 0, rejected = 0;
        for (Map<String, Object> p : all) {
            String s = String.valueOf(
                p.getOrDefault("STATUS", p.getOrDefault("status", ""))
            ).toUpperCase();
            switch (s) {
                case "PENDING"              -> pending++;
                case "ACTIVE"               -> active++;
                case "SUSPENDED", "BLOCKED" -> suspended++;
                case "REJECTED"             -> rejected++;
            }
        }
        return PartnerKpiDto.builder()
            .total(active + suspended + rejected)
            .pending(pending)
            .active(active)
            .suspended(suspended)
            .rejected(rejected)
            .approvedThisMonth(0)
            .totalSalesLabel("-")
            .lowRatingCount(0)
            .build();
    }

    // ── 상태 변경 ────────────────────────────────────────────
    @Override @Transactional
    public void approvePartner(Long partnerId, Double commissionRate) {
        int affected = partnerMapper.updatePartnerStatus(Map.of(
            "partnerId", partnerId, "commissionRate", commissionRate, "status", "ACTIVE"
        ));
        if (affected == 0) throw new IllegalArgumentException("파트너 없음 ID:" + partnerId);
        log.info("승인 완료 ID:{}, 수수료:{}%", partnerId, commissionRate);
    }

    @Override @Transactional
    public void rejectPartner(Long partnerId, String rejectReason) {
        int affected = partnerMapper.updatePartnerStatus(Map.of(
            "partnerId", partnerId, "rejectReason", rejectReason, "status", "REJECTED"
        ));
        if (affected == 0) throw new IllegalArgumentException("파트너 없음 ID:" + partnerId);
        log.info("반려 완료 ID:{}", partnerId);
    }

    @Override @Transactional
    public void suspendPartner(Long partnerId) {
        int affected = partnerMapper.updatePartnerStatus(Map.of(
            "partnerId", partnerId, "status", "SUSPENDED"
        ));
        if (affected == 0) throw new IllegalArgumentException("파트너 없음 ID:" + partnerId);
        log.info("차단 완료 ID:{}", partnerId);
    }

    @Override @Transactional
    public void registerPartner(PartnerManageDto req) {
        Map<String, Object> params = new HashMap<>();
        params.put("partnerName",    req.getPartnerName());
        params.put("businessNumber", req.getBusinessNumber());
        params.put("contactName",    req.getContactName()  != null ? req.getContactName()  : "");
        params.put("contactPhone",   req.getContactPhone() != null ? req.getContactPhone() : "");
        params.put("commissionRate", req.getCommissionRate() != null
            ? req.getCommissionRate().doubleValue() : 10.0);
        partnerMapper.insertPartner(params);
        log.info("신규 등록 완료: {}", req.getPartnerName());
    }
}