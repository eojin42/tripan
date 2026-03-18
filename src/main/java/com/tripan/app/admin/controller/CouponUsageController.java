package com.tripan.app.admin.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.tripan.app.admin.domain.dto.CouponUsageDto;
import com.tripan.app.admin.service.CouponUsageService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/admin/coupon-usage")
@RequiredArgsConstructor
public class CouponUsageController {

    private final CouponUsageService couponUsageService;

    @PostMapping
    public ResponseEntity<Long> create(@RequestBody CouponUsageDto.SaveRequest request) {
        return ResponseEntity.ok(couponUsageService.createCouponUsage(request));
    }

    @PutMapping("/{usageId}/cancel")
    public ResponseEntity<Void> cancel(@PathVariable("usageId") Long usageId,
                                       @RequestBody(required = false) CouponUsageDto.CancelRequest request) {
        CouponUsageDto.CancelRequest cancelRequest = request == null
                ? CouponUsageDto.CancelRequest.builder().usageId(usageId).build()
                : CouponUsageDto.CancelRequest.builder()
                    .usageId(usageId)
                    .cancelReason(request.getCancelReason())
                    .build();
        couponUsageService.cancelCouponUsage(cancelRequest);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/{usageId}")
    public ResponseEntity<CouponUsageDto> detail(@PathVariable("usageId") Long usageId) {
        return ResponseEntity.ok(couponUsageService.getCouponUsage(usageId));
    }

    @GetMapping("/order/{orderId}")
    public ResponseEntity<CouponUsageDto> detailByOrder(@PathVariable("orderId") String orderId) {
        return ResponseEntity.ok(couponUsageService.getCouponUsageByOrderId(orderId));
    }

    @GetMapping
    public ResponseEntity<List<CouponUsageDto>> list(CouponUsageDto.SearchRequest request) {
        return ResponseEntity.ok(couponUsageService.getCouponUsageList(request));
    }

    @GetMapping("/summary")
    public ResponseEntity<CouponUsageDto.SummaryResponse> summary(CouponUsageDto.SearchRequest request) {
        return ResponseEntity.ok(couponUsageService.getCouponUsageSummary(request));
    }
}
