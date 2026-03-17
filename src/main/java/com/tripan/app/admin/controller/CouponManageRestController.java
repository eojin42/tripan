package com.tripan.app.admin.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.tripan.app.admin.domain.dto.CouponDto;
import com.tripan.app.admin.service.CouponService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/admin/coupon")
@RequiredArgsConstructor
public class CouponManageRestController {

    private final CouponService couponService;

    /* ── KPI ── */
    @GetMapping("/kpi")
    public ResponseEntity<CouponDto.KpiResponse> getKpi() {
        return ResponseEntity.ok(couponService.getKpi());
    }

    /* ── 쿠폰 목록 ── */
    @GetMapping("/list")
    public ResponseEntity<CouponDto.PageResponse<CouponDto.ListItem>> getCouponList(
            @RequestParam(value="page",defaultValue = "1")    int    page,
            @RequestParam(value="discountType",defaultValue = "ALL")  String discountType,
            @RequestParam(value="status",defaultValue = "ALL")  String status,
            @RequestParam(value="issuer",defaultValue = "ALL")  String issuer,
            @RequestParam(value="keyword",defaultValue = "")     String keyword) {

        return ResponseEntity.ok(
                couponService.getCouponList(page, discountType, status, issuer, keyword));
    }

    /* ── 승인 대기 목록 ── */
    @GetMapping("/pending")
    public ResponseEntity<List<CouponDto.ListItem>> getPendingList() {
        return ResponseEntity.ok(couponService.getPendingList());
    }

    /* ── 쿠폰 등록 ── */
    @PostMapping("/register")
    public ResponseEntity<Void> register(@RequestBody CouponDto.SaveRequest req) {
        couponService.registerCoupon(req);
        return ResponseEntity.ok().build();
    }

    /* ── 쿠폰 수정 ── */
    @GetMapping("/{couponId}")
    public ResponseEntity<?> getCoupon(@PathVariable("couponId") Long couponId) {
        try {
            CouponDto.ListItem coupon = couponService.getCouponById(couponId);
            if (coupon == null) return ResponseEntity.notFound().build();
            return ResponseEntity.ok(coupon);
        } catch (Exception e) {
            return ResponseEntity.status(500).build();
        }
    }
    
    @PutMapping("/{couponId}")
    public ResponseEntity<Void> update(@PathVariable("couponId") Long couponId,
            @RequestBody CouponDto.SaveRequest req) {
        couponService.updateCoupon(couponId, req);
        return ResponseEntity.ok().build();
    }

    /* ── 승인/반려 ── */
    @PostMapping("/{couponId}/review")
    public ResponseEntity<Void> review(@PathVariable("couponId") Long couponId,
            @RequestBody CouponDto.ReviewRequest req) {
        couponService.reviewCoupon(couponId, req);
        return ResponseEntity.ok().build();
    }

    /* ── 삭제 ── */
    @DeleteMapping
    public ResponseEntity<Void> delete(@RequestBody CouponDto.DeleteRequest req) {
        couponService.deleteCoupons(req.getCouponIds());
        return ResponseEntity.ok().build();
    }

    /* ── 회원 발급 현황 ── */
    @GetMapping("/issued")
    public ResponseEntity<CouponDto.PageResponse<CouponDto.IssuedItem>> getIssuedList(
            @RequestParam(value="page", defaultValue = "1")   int    page,
            @RequestParam(value="status", defaultValue = "ALL") String status,
            @RequestParam(value="couponKeyword", defaultValue = "")    String couponKeyword,
            @RequestParam(value="memberKeyword", defaultValue = "")    String memberKeyword) {

        return ResponseEntity.ok(
                couponService.getIssuedList(page, status, couponKeyword, memberKeyword));
    }
}

