package com.tripan.app.partner.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;

import com.tripan.app.partner.domain.dto.PartnerCouponDto;
import com.tripan.app.partner.mapper.PartnerCouponMapper;

import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class PartnerCouponServiceImpl implements PartnerCouponService {

    private final PartnerCouponMapper partnerCouponMapper;

    @Override
    public List<PartnerCouponDto> getCouponList(Map<String, Object> searchParams) {
        
        return partnerCouponMapper.selectCouponListForPartner(searchParams);
    }

    @Override
    public Map<String, Object> getCouponKpiStats(Long partnerId) {
        return partnerCouponMapper.selectCouponKpiStats(partnerId);
    }
    
    @Override
    @Transactional 
    public void createPartnerCoupon(PartnerCouponDto dto, Long partnerId, String targetPlaceId) {
        
        partnerCouponMapper.insertCoupon(dto);
        
        Map<String, Object> targetMap = new HashMap<>();
        targetMap.put("couponId", dto.getCouponId());
        targetMap.put("partnerId", partnerId);
        
        targetMap.put("targetType", "ACCOMMODATION");
        targetMap.put("targetValue", targetPlaceId);
        targetMap.put("placeId", Long.valueOf(targetPlaceId));
        
        partnerCouponMapper.insertCouponTarget(targetMap);
    }
    
    @Override
    public void stopCoupon(Long couponId) {
        partnerCouponMapper.updateCouponStatus(couponId, "EXPIRED");
    }
    
    @Override
    public Map<String, Object> getPagedCouponList(Map<String, Object> searchParams) {
        int page = Integer.parseInt(searchParams.get("page").toString());
        int limit = Integer.parseInt(searchParams.get("limit").toString());
        
        int offset = (page - 1) * limit;
        searchParams.put("offset", offset); 
        
        List<PartnerCouponDto> couponList = partnerCouponMapper.selectCouponListForPartner(searchParams);
        int totalCount = partnerCouponMapper.countCouponListForPartner(searchParams);
        
        int totalPages = (int) Math.ceil((double) totalCount / limit);
        if(totalPages == 0) totalPages = 1; // 쿠폰이 하나도 없어도 1페이지는 출력되도록 처리

        Map<String, Object> resultMap = new HashMap<>();
        resultMap.put("couponList", couponList);
        resultMap.put("totalPages", totalPages);
        
        return resultMap;
    }

}