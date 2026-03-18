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

import com.tripan.app.admin.domain.dto.PartnerKpiDto;
import com.tripan.app.admin.domain.dto.PartnerManageDto;
import com.tripan.app.admin.service.PartnerManageService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@RestController
@RequiredArgsConstructor
@RequestMapping("api/admin/partner")
public class PartnerManageRestController {

	private final PartnerManageService partnerService;
	 
    /* ── KPI ── */
    @GetMapping("/kpi")
    public ResponseEntity<PartnerKpiDto> getKpi() {
        return ResponseEntity.ok(partnerService.getKpi());
    }
 
    /* apply 화면도 동일 KPI 사용 */
    @GetMapping("/apply/kpi")
    public ResponseEntity<PartnerKpiDto> getApplyKpi() {
        return ResponseEntity.ok(partnerService.getKpi());
    }
 
    /* ── 전체 목록 ── */
    @GetMapping("/list")
    public ResponseEntity<Map<String, Object>> getList() {
        List<PartnerManageDto> list = partnerService.getAllPartners();
        Map<String, Object> result = new HashMap<>();
        result.put("list",       list);
        result.put("totalCount", list.size());
        result.put("pagination", null); // 프론트에서 페이징 처리
        return ResponseEntity.ok(result);
    }
 
    /* ── 활성 파트너 옵션 (쿠폰 등록 select용) ── */
    @GetMapping("/options")
    public ResponseEntity<List<PartnerManageDto>> getOptions() {
        return ResponseEntity.ok(partnerService.getActivePartners());
    }
 
    /* ── 신규 등록 ── */
    @PostMapping("/register")
    public ResponseEntity<String> register(@RequestBody PartnerManageDto req) {
        if (req.getPartnerName() == null || req.getPartnerName().isBlank()
         || req.getBusinessNumber() == null || req.getBusinessNumber().isBlank()) {
            return ResponseEntity.badRequest().body("파트너사명과 사업자번호는 필수입니다.");
        }
        partnerService.registerPartner(req);
        return ResponseEntity.ok("등록 완료");
    }
 
    /* ── 심사 처리 (승인 / 반려) ── */
    @PostMapping("/apply/review")
    public ResponseEntity<String> review(@RequestBody PartnerManageDto req) {
        if (req.getApplyId() == null || req.getResult() == null) {
            return ResponseEntity.badRequest().body("applyId와 result는 필수입니다.");
        }
        switch (req.getResult()) {
            case "APPROVED" -> {
                double rate = req.getCommissionRate() != null
                    ? req.getCommissionRate().doubleValue() : 10.0;
                partnerService.approvePartner(req.getApplyId(), rate);
            }
            case "REJECTED" -> partnerService.rejectPartner(req.getApplyId(), req.getMessage());
            default -> { return ResponseEntity.badRequest().body("잘못된 result: " + req.getResult()); }
        }
        return ResponseEntity.ok("처리 완료");
    }
 
    /* ── 차단 ── */
    @PostMapping("/suspend/{partnerId}")
    public ResponseEntity<String> suspend(@PathVariable Long partnerId) {
        partnerService.suspendPartner(partnerId);
        return ResponseEntity.ok("차단 완료");
    }
 
    /* ── 활성화 (차단 해제) ── */
    @PostMapping("/activate")
    public ResponseEntity<String> activate(@RequestBody PartnerManageDto req) {
        partnerService.approvePartner(req.getApplyId(), 10.0);
        return ResponseEntity.ok("활성화 완료");
    }
}
