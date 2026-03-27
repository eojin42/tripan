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
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.tripan.app.admin.domain.dto.CouponDto;
import com.tripan.app.admin.mapper.CouponTargetMapper;
import com.tripan.app.admin.service.CouponService;
import com.tripan.app.domain.dto.AccommodationDto;
import com.tripan.app.domain.dto.MemberDto;
import com.tripan.app.domain.dto.RoomDto;
import com.tripan.app.service.MemberService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/admin/coupon")
@RequiredArgsConstructor
public class CouponManageRestController {

    private final CouponService couponService;
    private final CouponTargetMapper couponTargetMapper;
    private final MemberService memberService;

    @GetMapping("/kpi")
    public ResponseEntity<CouponDto.KpiResponse> getKpi() {
        return ResponseEntity.ok(couponService.getKpi());
    }

    @GetMapping("/list")
    public ResponseEntity<CouponDto.PageResponse<CouponDto.ListItem>> getCouponList(
            @RequestParam(value = "page", defaultValue = "1") int page,
            @RequestParam(value = "discountType", defaultValue = "ALL") String discountType,
            @RequestParam(value = "status", defaultValue = "ALL") String status,
            @RequestParam(value = "issuer", defaultValue = "ALL") String issuer,
            @RequestParam(value = "keyword", defaultValue = "") String keyword) {
        return ResponseEntity.ok(couponService.getCouponList(page, discountType, status, issuer, keyword));
    }

    @GetMapping("/pending")
    public ResponseEntity<List<CouponDto.ListItem>> getPendingList() {
        return ResponseEntity.ok(couponService.getPendingList());
    }

    @PostMapping("/register")
    public ResponseEntity<Void> register(@RequestBody CouponDto.SaveRequest req) {
        couponService.registerCoupon(req);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/{couponId}")
    public ResponseEntity<?> getCoupon(@PathVariable("couponId") Long couponId) {
        CouponDto.DetailResponse coupon = couponService.getCouponById(couponId);
        if (coupon == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(coupon);
    }

    @PostMapping("/{couponId}/update")
    public ResponseEntity<Void> update(@PathVariable("couponId") Long couponId,
                                       @RequestBody CouponDto.SaveRequest req) {
        couponService.updateCoupon(couponId, req);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/{couponId}/review")
    public ResponseEntity<Void> review(@PathVariable("couponId") Long couponId,
                                       @RequestBody CouponDto.ReviewRequest req) {
        couponService.reviewCoupon(couponId, req);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/delete")
    public ResponseEntity<Void> delete(@RequestBody CouponDto.DeleteRequest req) {
        couponService.deleteCoupons(req.getCouponIds());
        return ResponseEntity.ok().build();
    }

    @GetMapping("/issued")
    public ResponseEntity<CouponDto.PageResponse<CouponDto.IssuedItem>> getIssuedList(
            @RequestParam(value = "page", defaultValue = "1") int page,
            @RequestParam(value = "status", defaultValue = "ALL") String status,
            @RequestParam(value = "couponKeyword", defaultValue = "") String couponKeyword,
            @RequestParam(value = "memberKeyword", defaultValue = "") String memberKeyword) {
        return ResponseEntity.ok(couponService.getIssuedList(page, status, couponKeyword, memberKeyword));
    }

    @PostMapping("/issued/{memberCouponId}/revoke")
    public ResponseEntity<Void> revokeIssuedCoupon(@PathVariable("memberCouponId") Long memberCouponId) {
        couponService.revokeCoupon(memberCouponId);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/accommodation/types")
    public ResponseEntity<List<String>> getAccommodationTypes() {
        return ResponseEntity.ok(couponTargetMapper.selectAccTypeOptions());
    }

    @GetMapping("/accommodation/search")
    public ResponseEntity<List<AccommodationDto>> searchAccommodations(
            @RequestParam(value = "keyword", required = false) String keyword,
            @RequestParam(value = "accommodationType", required = false) String accommodationType) {

        Map<String, Object> params = new HashMap<>();
        params.put("keyword", keyword);
        params.put("accommodationType", accommodationType);
        return ResponseEntity.ok(couponTargetMapper.searchAccommodations(params));
    }

    @GetMapping("/accommodation/{placeId}/rooms")
    public ResponseEntity<List<RoomDto>> getRooms(
            @PathVariable("placeId") Long placeId,
            @RequestParam(value = "keyword", required = false) String keyword) {
        return ResponseEntity.ok(couponTargetMapper.selectRoomsByAccommodation(placeId, keyword));
    }
    
    @GetMapping("/member/search")
    public ResponseEntity<List<MemberDto>> searchMembers(
            @RequestParam(value = "keyword") String keyword) {
        return ResponseEntity.ok(memberService.searchByKeyword(keyword));
    }

    @PostMapping("/grant")
    public ResponseEntity<Void> grant(@RequestBody CouponDto.GrantRequest req) {
        couponService.grantCoupon(req);
        return ResponseEntity.ok().build();
    }
}