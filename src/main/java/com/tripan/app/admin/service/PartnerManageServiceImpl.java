package com.tripan.app.admin.service;

import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.tripan.app.admin.domain.dto.PartnerKpiDto;
import com.tripan.app.admin.domain.dto.PartnerManageDto;
import com.tripan.app.admin.mapper.PartnerManageMapper;
import com.tripan.app.mail.Mail;
import com.tripan.app.mail.MailSender;
import com.tripan.app.mail.PartnerMailTemplates;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class PartnerManageServiceImpl implements PartnerManageService {

    private final PartnerManageMapper partnerMapper;
    private final MailSender          mailSender;

    // ── 조회 ────────────────────────────────────────────────

    @Override
    public List<PartnerManageDto> getAllPartners() {
        List<PartnerManageDto> list = partnerMapper.selectAllPartners();

        // 이번 달 매출 → salesLabel / salesRatio 가공
        long maxSales = list.stream()
            .mapToLong(p -> p.getMonthlySales() != null ? p.getMonthlySales() : 0L)
            .max().orElse(1L);

        list.forEach(p -> {
            long sales = p.getMonthlySales() != null ? p.getMonthlySales() : 0L;
            p.setSalesRatio((int)(sales * 100 / Math.max(maxSales, 1)));
            if (sales >= 100_000_000L)
                p.setSalesLabel(String.format("%.1f억원", sales / 100_000_000.0));
            else if (sales >= 10_000L)
                p.setSalesLabel(String.format("%.0f만원", sales / 10_000.0));
            else
                p.setSalesLabel(sales == 0 ? "-" : sales + "원");
        });

        return list;
    }

    @Override
    public List<PartnerManageDto> getActivePartners() {
        return partnerMapper.selectActivePartners();
    }

    @Override
    public PartnerManageDto getPartnerDetail(Long partnerId) {
        PartnerManageDto dto = partnerMapper.selectPartnerDetail(partnerId);
        if (dto == null) throw new IllegalArgumentException("파트너 없음 ID:" + partnerId);
        dto.setApplyId(dto.getPartnerId());
        return dto;
    }

    @Override
    public PartnerKpiDto getKpi() {
        List<PartnerManageDto> all = partnerMapper.selectAllPartners();
        int pending = 0, active = 0, suspended = 0, rejected = 0;
        int lowRatingCount = 0;

        for (PartnerManageDto p : all) {
            String sc = p.getStatusCode() != null ? p.getStatusCode().toUpperCase() : "";
            String s  = !sc.isEmpty() ? sc
                      : (p.getStatus() != null ? (p.getStatus() == 1 ? "ACTIVE" : "SUSPENDED") : "");
            switch (s) {
                case "PENDING"              -> pending++;
                case "ACTIVE"               -> active++;
                case "SUSPENDED", "BLOCKED" -> suspended++;
                case "REJECTED"             -> rejected++;
            }
            if (p.getRating() != null && p.getRating() < 3.0) {
                lowRatingCount++;
            }
        }

        long totalSales = partnerMapper.selectTotalMonthlySales();
        String totalSalesLabel;
        if (totalSales >= 100_000_000L)
            totalSalesLabel = String.format("%.1f억원", totalSales / 100_000_000.0);
        else if (totalSales >= 10_000L)
            totalSalesLabel = String.format("%.0f만원", totalSales / 10_000.0);
        else
            totalSalesLabel = totalSales == 0 ? "-" : totalSales + "원";

        return PartnerKpiDto.builder()
            .total(active + suspended + rejected)
            .pending(pending)
            .active(active)
            .suspended(suspended)
            .rejected(rejected)
            .approvedThisMonth(partnerMapper.selectApprovedThisMonth())
            .totalSalesLabel(totalSalesLabel)
            .lowRatingCount(lowRatingCount)
            .build();
    }

    // ── 숙소 목록 ────────────────────────────────────────────

    @Override
    public List<Map<String, Object>> getPlacesByPartnerId(Long partnerId) {
        return partnerMapper.selectPlacesByPartnerId(partnerId);
    }

    // ── 예약 내역 ─────────────────────────────────────────────

    @Override
    public List<Map<String, Object>> getReservationsByPartnerId(Long partnerId) {
        return partnerMapper.selectReservationsByPartnerId(partnerId);
    }

    // ── 상태 변경 ─────────────────────────────────────────────

    @Override
    @Transactional
    public void approvePartner(Long partnerId, Double commissionRate, Date contractEndDate) {
        partnerMapper.updatePartnerStatus(Map.of(
            "partnerId",  partnerId,
            "status",     "ACTIVE",
            "memo",       commissionRate != null ? "수수료율 " + commissionRate + "%" : "",
            "registerId", 0L
        ));
        partnerMapper.updatePartnerActiveStatus(Map.of(
            "partnerId",      partnerId,
            "activeStatus",   1,
            "commissionRate", commissionRate
        ));
        if (contractEndDate != null) {
            partnerMapper.insertPartnerContract(Map.of(
                "partnerId",       partnerId,
                "contractEndDate", contractEndDate
            ));
        }
        PartnerManageDto partner = partnerMapper.selectPartnerDetail(partnerId);
        if (partner.getMemberId() != null) {
            partnerMapper.updateMemberRoleToPartner(Map.of("memberId", partner.getMemberId()));
        }
        log.info("승인 완료 ID:{}, 수수료:{}%", partnerId, commissionRate);
        sendMail(partner.getContactEmail(),
            PartnerMailTemplates.approveSubject(),
            PartnerMailTemplates.approveContent(partner.getPartnerName(), commissionRate, contractEndDate)
        );
    }

    @Override
    @Transactional
    public void rejectPartner(Long partnerId, String rejectReason) {
        partnerMapper.updatePartnerStatus(Map.of(
            "partnerId",  partnerId,
            "status",     "REJECTED",
            "memo",       rejectReason != null ? rejectReason : "",
            "registerId", 0L
        ));
        log.info("반려 완료 ID:{}", partnerId);
        PartnerManageDto partner = partnerMapper.selectPartnerDetail(partnerId);
        sendMail(partner.getContactEmail(),
            PartnerMailTemplates.rejectSubject(),
            PartnerMailTemplates.rejectContent(partner.getPartnerName(), rejectReason)
        );
    }

    @Override
    @Transactional
    public void suspendPartner(Long partnerId) {
        partnerMapper.updatePartnerStatus(Map.of(
            "partnerId",  partnerId,
            "status",     "SUSPENDED",
            "memo",       "",
            "registerId", 0L
        ));
        partnerMapper.updatePartnerActiveStatus(Map.of(
            "partnerId",    partnerId,
            "activeStatus", 0
        ));
        log.info("차단 완료 ID:{}", partnerId);
    }

    @Override
    @Transactional
    public void expireContracts() {
        List<Long> expiredIds = partnerMapper.selectExpiredPartnerIds();
        for (Long id : expiredIds) {
            partnerMapper.updatePartnerStatus(Map.of(
                "partnerId",  id,
                "status",     "SUSPENDED",
                "memo",       "계약 만료 자동 정지",
                "registerId", 0L
            ));
            partnerMapper.updatePartnerActiveStatus(Map.of(
                "partnerId",    id,
                "activeStatus", 0
            ));
            log.info("계약 만료로 정지 처리 ID:{}", id);
        }
    }

    @Override
    @Transactional
    public void registerPartner(PartnerManageDto req) {
        Map<String, Object> params = new HashMap<>();
        params.put("partnerName",    req.getPartnerName());
        params.put("businessNumber", req.getBusinessNumber());
        params.put("contactName",    req.getContactName()    != null ? req.getContactName()    : "");
        params.put("contactPhone",   req.getContactPhone()   != null ? req.getContactPhone()   : "");
        params.put("commissionRate", req.getCommissionRate() != null
            ? req.getCommissionRate().doubleValue() : 10.0);

        partnerMapper.insertPartner(params);

        Long newPartnerId = params.get("partnerId") != null
            ? Long.valueOf(params.get("partnerId").toString()) : null;
        if (newPartnerId != null) {
            partnerMapper.insertPartnerStatusPending(Map.of(
                "partnerId",  newPartnerId,
                "registerId", 0L
            ));
        }
        log.info("신규 등록 완료: {}", req.getPartnerName());
    }

    @Override
    public List<Map<String, Object>> getPartnerDocs(Long partnerId) {
        return partnerMapper.selectPartnerDocs(partnerId);
    }

    // ── 메일 발송 공통 ────────────────────────────────────────

    private void sendMail(String to, String subject, String content) {
        if (to == null || to.isBlank()) return;
        Mail mail = new Mail();
        mail.setReceiverEmail(to);
        mail.setSenderEmail("amandaejk@gmail.com");
        mail.setSenderName("TRIPAN 관리자");
        mail.setSubject(subject);
        mail.setContent(content);
        mailSender.mailSend(mail);
    }
}