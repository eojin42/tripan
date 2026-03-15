package com.tripan.app.admin.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@RestController
@RequiredArgsConstructor
@RequestMapping("/admin/api")
public class PartnerManageRestController {

    // private final PartnerService partnerService;

    /* 파트너 전체 목록 조회 */
    @GetMapping("/partners")
    public ResponseEntity<List<Map<String, Object>>> getPartners() {
        // 실제 구현: return ResponseEntity.ok(partnerService.getAllPartners());

        List<Map<String, Object>> dummyList = List.of(
            createDummy(1, "제주 신라호텔",  "123-45-67890", "김사장", "010-1111-2222", "WAITING",   10.0, null),
            createDummy(2, "부산 파라다이스", "987-65-43210", "이사장", "010-3333-4444", "ACTIVE",    12.0, null),
            createDummy(3, "강릉 씨마크",    "111-22-33333", "박사장", "010-5555-6666", "SUSPENDED", 10.0, "허위 매물 등록")
        );
        return ResponseEntity.ok(dummyList);
    }

    /*  파트너 옵션 목록 (쿠폰 등록 select용) */
    @GetMapping("/partner/options")
    public ResponseEntity<List<Map<String, Object>>> getPartnerOptions() {
        // 실제 구현: return ResponseEntity.ok(partnerService.getActivePartners());

        List<Map<String, Object>> dummyList = List.of(
            Map.of("partnerId", 1, "partnerName", "제주 신라호텔"),
            Map.of("partnerId", 2, "partnerName", "부산 파라다이스")
        );
        return ResponseEntity.ok(dummyList);
    }

    /* 3. 파트너 승인 */
    @PostMapping("/partner/approve")
    public ResponseEntity<String> approvePartner(@RequestBody Map<String, Object> payload) {
        Long   partnerId      = Long.valueOf(payload.get("partner_id").toString());
        Double commissionRate = Double.valueOf(payload.get("commission_rate").toString());

        // 실제 구현: partnerService.approvePartner(partnerId, commissionRate);
        log.info("승인 완료! ID: {}, 수수료: {}%", partnerId, commissionRate);
        return ResponseEntity.ok("승인 성공");
    }

    /* 파트너 반려 */
    @PostMapping("/partner/reject")
    public ResponseEntity<String> rejectPartner(@RequestBody Map<String, Object> payload) {
        Long   partnerId    = Long.valueOf(payload.get("partner_id").toString());
        String rejectReason = (String) payload.get("reject_reason");

        // 실제 구현: partnerService.rejectPartner(partnerId, rejectReason);
        log.info("반려 완료! ID: {}, 사유: {}", partnerId, rejectReason);
        return ResponseEntity.ok("반려 성공");
    }

    /* 파트너 차단 */
    @PostMapping("/partner/suspend/{partnerId}")
    public ResponseEntity<String> suspendPartner(@PathVariable("partnerId") Long partnerId) {
        // 실제 구현: partnerService.suspendPartner(partnerId);
        log.info("차단 완료! ID: {}", partnerId);
        return ResponseEntity.ok("차단 성공");
    }

    /* 더미 데이터 생성 헬퍼 */
    private Map<String, Object> createDummy(int id, String name, String bizNum,
                                             String cName, String cPhone,
                                             String status, Double rate, String reason) {
        Map<String, Object> map = new HashMap<>();
        map.put("partner_id",       id);
        map.put("partner_name",     name);
        map.put("business_number",  bizNum);
        map.put("contact_name",     cName);
        map.put("contact_phone",    cPhone);
        map.put("status",           status);
        map.put("commission_rate",  rate);
        map.put("reject_reason",    reason);
        map.put("created_at",       "2026-03-15");
        return map;
    }
}
