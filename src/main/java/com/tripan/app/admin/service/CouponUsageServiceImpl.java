package com.tripan.app.admin.service;

import java.math.BigDecimal;
import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import com.tripan.app.admin.domain.dto.CouponUsageDto;
import com.tripan.app.admin.mapper.CouponUsageMapper;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class CouponUsageServiceImpl implements CouponUsageService {

    private final CouponUsageMapper couponUsageMapper;

    @Override
    @Transactional
    public Long createCouponUsage(CouponUsageDto.SaveRequest request) {
        validateCreateRequest(request);

        CouponUsageDto dto = CouponUsageDto.builder()
                .orderId(request.getOrderId())
                .memberCouponId(request.getMemberCouponId())
                .couponId(request.getCouponId())
                .partnerId(request.getPartnerId())
                .placeId(request.getPlaceId())
                .discountAmount(nullToZero(request.getDiscountAmount()))
                .platformDiscountAmount(nullToZero(request.getPlatformDiscountAmount()))
                .partnerDiscountAmount(nullToZero(request.getPartnerDiscountAmount()))
                .status(StringUtils.hasText(request.getStatus()) ? request.getStatus() : "USED")
                .cancelReason(request.getCancelReason())
                .build();

        couponUsageMapper.insertCouponUsage(dto);
        return dto.getUsageId();
    }

    @Override
    @Transactional
    public void cancelCouponUsage(CouponUsageDto.CancelRequest request) {
        if (request == null || request.getUsageId() == null) {
            throw new IllegalArgumentException("usageId는 필수입니다.");
        }
        couponUsageMapper.updateCouponUsageStatus(request.getUsageId(), "CANCELLED", request.getCancelReason());
    }

    @Override
    public CouponUsageDto getCouponUsage(Long usageId) {
        return couponUsageMapper.selectCouponUsageById(usageId);
    }

    @Override
    public CouponUsageDto getCouponUsageByOrderId(String orderId) {
        return couponUsageMapper.selectCouponUsageByOrderId(orderId);
    }

    @Override
    public List<CouponUsageDto> getCouponUsageList(CouponUsageDto.SearchRequest request) {
        return couponUsageMapper.selectCouponUsageList(request);
    }

    @Override
    public CouponUsageDto.SummaryResponse getCouponUsageSummary(CouponUsageDto.SearchRequest request) {
        return couponUsageMapper.selectCouponUsageSummary(request);
    }

    private void validateCreateRequest(CouponUsageDto.SaveRequest request) {
        if (request == null) {
            throw new IllegalArgumentException("요청값이 없습니다.");
        }
        if (!StringUtils.hasText(request.getOrderId())) {
            throw new IllegalArgumentException("orderId는 필수입니다.");
        }
        if (request.getMemberCouponId() == null) {
            throw new IllegalArgumentException("memberCouponId는 필수입니다.");
        }
        if (request.getPartnerId() == null) {
            throw new IllegalArgumentException("partnerId는 필수입니다.");
        }
        if (request.getDiscountAmount() == null) {
            throw new IllegalArgumentException("discountAmount는 필수입니다.");
        }
    }

    private BigDecimal nullToZero(BigDecimal value) {
        return value == null ? BigDecimal.ZERO : value;
    }
}

