package com.tripan.app.admin.service;

import java.util.List;
import java.util.Map;
import java.util.Date;
import java.util.HashMap;

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
    private final MailSender mailSender;

    // ── 조회 ────────────────────────────────────────────────

    @Override
    public List<PartnerManageDto> getAllPartners() {
        return partnerMapper.selectAllPartners();
    }

    @Override
    public List<PartnerManageDto> getActivePartners() {
        return partnerMapper.selectActivePartners();
    }

    @Override
    public PartnerManageDto getPartnerDetail(Long partnerId) {
        PartnerManageDto dto = partnerMapper.selectPartnerDetail(partnerId);
        if (dto == null) throw new IllegalArgumentException("파트너 없음 ID:" + partnerId);
        dto.setApplyId(dto.getPartnerId()); // apply 화면에서 applyId로 심사 처리 시 사용
        return dto;
    }

    @Override
    public PartnerKpiDto getKpi() {
        List<PartnerManageDto> all = partnerMapper.selectAllPartners();
        int pending = 0, active = 0, suspended = 0, rejected = 0;
        for (PartnerManageDto p : all) {
            // statusCode(partner_status) 우선, 없으면 partner.status 숫자 폴백
            String sc = p.getStatusCode() != null ? p.getStatusCode().toUpperCase() : "";
            String s  = !sc.isEmpty() ? sc
                      : (p.getStatus() != null ? (p.getStatus() == 1 ? "ACTIVE" : "SUSPENDED") : "");
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
            .approvedThisMonth(partnerMapper.selectApprovedThisMonth())
            .totalSalesLabel("-")
            .lowRatingCount(0)
            .build();
    }

    // ── 상태 변경 ────────────────────────────────────────────

    @Override
    @Transactional
    public void approvePartner(Long partnerId, Double commissionRate, Date contractEndDate) {
        // partner_status INSERT (ACTIVE 이력 추가)
        partnerMapper.updatePartnerStatus(Map.of(
            "partnerId",  partnerId,
            "status",     "ACTIVE",
            "memo",       commissionRate != null ? "수수료율 " + commissionRate + "%" : "",
            "registerId", 0L  // TODO: SecurityContext 등에서 실제 관리자 memberId로 교체
        ));
        // partner.status = 1, commission_rate 업데이트
        partnerMapper.updatePartnerActiveStatus(Map.of(
            "partnerId",      partnerId,
            "activeStatus",   1,
            "commissionRate", commissionRate
        ));
        // 계약 등록
        if (contractEndDate != null) {
            partnerMapper.insertPartnerContract(Map.of(
                "partnerId",       partnerId,
                "contractEndDate", contractEndDate
            ));
        }
        log.info("승인 완료 ID:{}, 수수료:{}%", partnerId, commissionRate);
        PartnerManageDto partner = partnerMapper.selectPartnerDetail(partnerId);
        sendMail(partner.getContactEmail(),
            PartnerMailTemplates.approveSubject(),
            PartnerMailTemplates.approveContent(partner.getPartnerName(), commissionRate, contractEndDate)
        );
    }

    @Override
    @Transactional
    public void rejectPartner(Long partnerId, String rejectReason) {
        // partner_status INSERT (REJECTED), memo에 반려 사유 저장
        partnerMapper.updatePartnerStatus(Map.of(
            "partnerId",  partnerId,
            "status",     "REJECTED",
            "memo",       rejectReason != null ? rejectReason : "",
            "registerId", 0L  // TODO: 실제 관리자 memberId로 교체
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
        // partner_status INSERT (SUSPENDED)
        partnerMapper.updatePartnerStatus(Map.of(
            "partnerId",  partnerId,
            "status",     "SUSPENDED",
            "memo",       "",
            "registerId", 0L  // TODO: 실제 관리자 memberId로 교체
        ));
        // partner.status = 0 (비활성)
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

        partnerMapper.insertPartner(params); // useGeneratedKeys → params에 partnerId 자동 채워짐

        Long newPartnerId = params.get("partnerId") != null
            ? Long.valueOf(params.get("partnerId").toString()) : null;
        if (newPartnerId != null) {
            partnerMapper.insertPartnerStatusPending(Map.of(
                "partnerId",  newPartnerId,
                "registerId", 0L  // TODO: 실제 관리자 memberId로 교체
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
        mail.setSenderEmail("tripan@tripan.com");
        mail.setSenderName("TRIPAN 관리자");
        mail.setSubject(subject);
        mail.setContent(content);
        mailSender.mailSend(mail);
    }
}