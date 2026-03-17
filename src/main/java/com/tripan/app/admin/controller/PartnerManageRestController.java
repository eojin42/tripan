package com.tripan.app.admin.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.tripan.app.admin.service.PartnerManageService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@RestController
@RequiredArgsConstructor
@RequestMapping("/admin/partner")
public class PartnerManageRestController {

    private final PartnerManageService partnerService;

    // Oracle DATE → "yyyy-MM-dd" 포맷 변환 헬퍼
    private String formatDate(Object dateObj) {
        if (dateObj == null) return "-";
        String raw = dateObj.toString();
        try {
            if (raw.contains("T")) {
                return raw.substring(0, 10);
            } else if (raw.contains(" ")) {
                return raw.substring(0, 10);
            }
            return raw.length() >= 10 ? raw.substring(0, 10) : raw;
        } catch (Exception e) {
            return raw;
        }
    }

    @GetMapping("/apply/kpi")
    public ResponseEntity<Map<String, Object>> getKpi() {
        Map<String, Object> kpi = new HashMap<>();
        kpi.put("total", 0);
        kpi.put("active", 0);
        kpi.put("suspended", 0);
        kpi.put("pending", 0);
        kpi.put("totalSalesLabel", "-");
        kpi.put("lowRatingCount", 0);
        return ResponseEntity.ok(kpi);
    }

    /* 파트너 전체 목록 조회 */
    @GetMapping("/apply/list")
    public ResponseEntity<List<Map<String, Object>>> getPartners() {
        return ResponseEntity.ok(partnerService.getAllPartners());
    }

    /* 파트너 옵션 목록 (쿠폰 등록 select용) */
    @GetMapping("/options")
    public ResponseEntity<List<Map<String, Object>>> getPartnerOptions() {
        return ResponseEntity.ok(partnerService.getActivePartners());
    }

    /* 입점 심사 처리 (승인/반려/보완 통합) */
    @PostMapping("/apply/review")
    public ResponseEntity<String> reviewPartner(@RequestBody Map<String, Object> payload) {
        Long   partnerId      = Long.valueOf(payload.get("applyId").toString());
        String result         = (String) payload.get("result");
        String message        = (String) payload.get("message");
        Object commissionRateObj = payload.get("commissionRate");

        switch (result) {
            case "APPROVED" -> {
                Double commissionRate = commissionRateObj != null
                    ? Double.valueOf(commissionRateObj.toString()) : 10.0;
                partnerService.approvePartner(partnerId, commissionRate);
                log.info("승인 완료! ID: {}, 수수료: {}%", partnerId, commissionRate);
            }
            case "REJECTED" -> {
                partnerService.rejectPartner(partnerId, message);
                log.info("반려 완료! ID: {}, 사유: {}", partnerId, message);
            }
            case "SUPPLEMENT" -> {
                log.info("보완 요청! ID: {}, 내용: {}", partnerId, message);
            }
            default -> { return ResponseEntity.badRequest().body("잘못된 결과값: " + result); }
        }
        return ResponseEntity.ok("처리 완료");
    }

    /* 파트너 차단 */
    @PostMapping("/suspend/{partnerId}")
    public ResponseEntity<String> suspendPartner(@PathVariable("partnerId") Long partnerId) {
        partnerService.suspendPartner(partnerId);
        log.info("차단 완료! ID: {}", partnerId);
        return ResponseEntity.ok("차단 성공");
    }

    /* ── KPI ── */
    @GetMapping("/kpi")
    public ResponseEntity<Map<String, Object>> getMainKpi() {
        List<Map<String, Object>> partners = partnerService.getAllPartners();

        int total     = partners.size();
        int pending   = 0;
        int supplement= 0;
        int approved  = 0;
        int rejected  = 0;

        for (Map<String, Object> p : partners) {
            String status = String.valueOf(p.getOrDefault("STATUS", p.getOrDefault("status", "")));

            switch (status.toUpperCase()) {
                case "PENDING"    -> pending++;
                case "SUPPLEMENT" -> supplement++;
                case "APPROVED", "ACTIVE" -> approved++;
                case "REJECTED", "BLOCKED", "SUSPENDED" -> rejected++;
            }
        }

        Map<String, Object> kpi = new HashMap<>();
        kpi.put("total",              total);
        kpi.put("pending",            pending);
        kpi.put("supplement",         supplement);
        kpi.put("approved",           approved);
        kpi.put("rejected",           rejected);
        kpi.put("active",             approved);
        kpi.put("suspended",          rejected);
        kpi.put("approvedThisMonth",  0);
        kpi.put("totalSalesLabel",    "-");
        kpi.put("lowRatingCount",     0);

        return ResponseEntity.ok(kpi);
    }

    /* ── 목록 ── */
    @GetMapping("/list")
    public ResponseEntity<Map<String, Object>> getMainList(
            @RequestParam(value = "page",    defaultValue = "1")   int page,
            @RequestParam(value = "status",  required = false, defaultValue = "ALL") String status,
            @RequestParam(value = "keyword", required = false, defaultValue = "")    String keyword) {

        List<Map<String, Object>> rawList = partnerService.getAllPartners();

        List<Map<String, Object>> filtered = rawList.stream()
            .filter(row -> {
                if (status == null || status.trim().isEmpty() || "ALL".equalsIgnoreCase(status)) return true;
                String rowStatus = String.valueOf(row.getOrDefault("STATUS", row.getOrDefault("status", "")));
                return status.equalsIgnoreCase(rowStatus);
            })
            .filter(row -> {
                if (keyword == null || keyword.trim().isEmpty()) return true;
                Object nameObj = row.getOrDefault("PARTNERNAME", row.getOrDefault("partnerName", ""));
                String name = nameObj == null ? "" : nameObj.toString();
                return name.contains(keyword.trim());
            })
            .collect(Collectors.toList());

        List<Map<String, Object>> list = filtered.stream()
            .map(row -> {
                Map<String, Object> item = new HashMap<>();

                Object pid = row.getOrDefault("PARTNERID", row.getOrDefault("partnerId", null));
                item.put("partnerId",       pid);
                item.put("applyId",         pid);

                item.put("partnerName",     row.getOrDefault("PARTNERNAME",    row.getOrDefault("partnerName", "-")));
                item.put("bizNo",           row.getOrDefault("BUSINESSNUMBER", row.getOrDefault("businessNumber", "-")));
                item.put("managerName",     row.getOrDefault("CONTACTNAME",    row.getOrDefault("contactName", "-")));
                item.put("managerPhone",    row.getOrDefault("CONTACTPHONE",   row.getOrDefault("contactPhone", "-")));
                item.put("commissionRate",  row.getOrDefault("COMMISSIONRATE", row.getOrDefault("commissionRate", 0)));
                item.put("rejectReason",    row.getOrDefault("REJECTREASON",   row.getOrDefault("rejectReason", null)));
                item.put("contractFileUrl", row.getOrDefault("CONTRACTFILEURL",row.getOrDefault("contractFileUrl", null)));

                Object createdAt = row.getOrDefault("CREATEDAT", row.getOrDefault("createdAt", null));
                String regDate   = formatDate(createdAt);
                item.put("regDate",   regDate);
                item.put("createdAt", regDate);
                item.put("applyDate", regDate);

                // 상태값
                String rawStatus = String.valueOf(row.getOrDefault("STATUS", row.getOrDefault("status", "")));
                item.put("status", rawStatus);

                String statusLabel = switch (rawStatus.toUpperCase()) {
                    case "PENDING"    -> "승인대기";
                    case "SUPPLEMENT" -> "보완요청";
                    case "APPROVED"   -> "승인완료";
                    case "ACTIVE"     -> "정상운영";
                    case "REJECTED"   -> "반려";
                    case "SUSPENDED"  -> "이용정지";
                    case "BLOCKED"    -> "영구차단";
                    default           -> rawStatus;
                };
                item.put("statusLabel", statusLabel);

                // 프론트에서 사용하는 필드 (현재 DB에 없으면 기본값)
                item.put("salesRatio",    0);
                item.put("salesLabel",    "-");
                item.put("rating",        0.0);
                item.put("reviewCount",   0);
                item.put("productCount",  0);
                item.put("riskLevel",     "LOW");
                item.put("categoryLabel", "-");

                return item;
            })
            .collect(Collectors.toList());

        Map<String, Object> result = new HashMap<>();
        result.put("list",       list);
        result.put("totalCount", list.size());
        result.put("pagination", null);

        return ResponseEntity.ok(result);
    }
}
