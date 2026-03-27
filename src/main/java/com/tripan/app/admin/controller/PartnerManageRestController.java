package com.tripan.app.admin.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.tripan.app.admin.domain.dto.PartnerKpiDto;
import com.tripan.app.admin.domain.dto.PartnerManageDto;
import com.tripan.app.admin.service.PartnerManageService;
import com.tripan.app.common.StorageService;
import com.tripan.app.exception.StorageException;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@RestController
@RequiredArgsConstructor
@RequestMapping("/api/admin/partner")
public class PartnerManageRestController {

    private final PartnerManageService partnerService;
    private final StorageService       storageService;

    @Value("${file.upload-root}")
    private String uploadRoot;

    /* ── KPI ── */
    @GetMapping("/kpi")
    public ResponseEntity<PartnerKpiDto> getKpi() {
        return ResponseEntity.ok(partnerService.getKpi());
    }

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
        result.put("pagination", null);
        return ResponseEntity.ok(result);
    }

    /* ── 활성 파트너 옵션 ── */
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

    /* ── 파트너 상세 조회 ── */
    @GetMapping("/detail/{partnerId}")
    public ResponseEntity<PartnerManageDto> getDetail(
            @PathVariable("partnerId") Long partnerId) {
        return ResponseEntity.ok(partnerService.getPartnerDetail(partnerId));
    }

    /* ── 운영중인 숙소 목록 ── */
    @GetMapping("/detail/{partnerId}/places")
    public ResponseEntity<List<Map<String, Object>>> getPartnerPlaces(
            @PathVariable("partnerId") Long partnerId) {
        return ResponseEntity.ok(partnerService.getPlacesByPartnerId(partnerId));
    }

    /* ── 예약 내역 목록 ── */
    @GetMapping("/detail/{partnerId}/reservations")
    public ResponseEntity<List<Map<String, Object>>> getPartnerReservations(
            @PathVariable("partnerId") Long partnerId) {
        return ResponseEntity.ok(partnerService.getReservationsByPartnerId(partnerId));
    }

    /* ── 심사 처리 ── */
    @PostMapping("/apply/review")
    public ResponseEntity<String> review(@RequestBody PartnerManageDto req) {
        if (req.getApplyId() == null || req.getStatusCode() == null) {
            return ResponseEntity.badRequest().body("applyId와 statusCode는 필수입니다.");
        }
        switch (req.getStatusCode().toUpperCase()) {
            case "APPROVED" -> {
                double rate = req.getCommissionRate() != null
                    ? req.getCommissionRate().doubleValue() : 10.0;
                partnerService.approvePartner(req.getApplyId(), rate, req.getContractEndDate());
            }
            case "REJECTED" -> partnerService.rejectPartner(req.getApplyId(), req.getMessage());
            default -> { return ResponseEntity.badRequest().body("잘못된 statusCode: " + req.getStatusCode()); }
        }
        return ResponseEntity.ok("처리 완료");
    }

    /* ── 차단 ── */
    @PostMapping("/suspend/{partnerId}")
    public ResponseEntity<String> suspend(
            @PathVariable("partnerId") Long partnerId) {
        partnerService.suspendPartner(partnerId);
        return ResponseEntity.ok("차단 완료");
    }

    /* ── 활성화 ── */
    @PostMapping("/activate")
    public ResponseEntity<String> activate(@RequestBody PartnerManageDto req) {
        Long id = req.getPartnerId() != null ? req.getPartnerId() : req.getApplyId();
        partnerService.approvePartner(id, 10.0, null);
        return ResponseEntity.ok("활성화 완료");
    }

    /* ── 제출 서류 목록 ── */
    @GetMapping("/apply/docs")
    public ResponseEntity<List<Map<String, Object>>> getApplyDocs(
            @RequestParam("applyId") Long applyId) {
        return ResponseEntity.ok(partnerService.getPartnerDocs(applyId));
    }

    @GetMapping("/apply/docs/download")
    public ResponseEntity<?> downloadDoc(
            @RequestParam("fileUrl")  String fileUrl,
            @RequestParam("fileName") String fileName) {
        try {
            log.info("[파일다운로드] fileUrl={} fileName={}", fileUrl, fileName);

            // /uploads/partner/uuid_파일명.png → 파일명 분리
            int lastSlash   = fileUrl.lastIndexOf("/");
            String saveFilename = fileUrl.substring(lastSlash + 1); // uuid_파일명.png

            // webDir: /uploads/partner → /partner (uploadRoot 이후 경로)
            // uploadRoot = .../tripan/uploads
            // fileUrl    = /uploads/partner/xxx.png
            // → uploads/ 이후: partner/xxx.png
            // → dirPath  = uploadRoot + /partner
            String afterUploads = fileUrl.replaceFirst("^/uploads", ""); // /partner/uuid_...png
            String subDir = afterUploads.substring(0, afterUploads.lastIndexOf("/")); // /partner

            String realDirPath = uploadRoot + subDir.replace("/", java.io.File.separator);
            log.info("[파일다운로드] realDirPath={} file={}", realDirPath, saveFilename);

            return storageService.downloadFile(realDirPath, saveFilename, fileName);

        } catch (StorageException e) {
            log.warn("[파일다운로드] 파일 없음: {}", fileUrl);
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            log.error("[파일다운로드] 오류: {}", fileUrl, e);
            return ResponseEntity.internalServerError().body("파일 다운로드 중 오류: " + e.getMessage());
        }
    }
}