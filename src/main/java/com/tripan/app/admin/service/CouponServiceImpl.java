package com.tripan.app.admin.service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.tripan.app.admin.domain.dto.CouponDto;
import com.tripan.app.admin.domain.dto.CouponTargetDto;
import com.tripan.app.admin.mapper.CouponMapper;
import com.tripan.app.admin.mapper.CouponTargetMapper;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class CouponServiceImpl implements CouponService {

    private final CouponMapper couponMapper;
    private final CouponTargetMapper couponTargetMapper;

    private static final int PAGE_SIZE = 10;
    private static final int BLOCK_SIZE = 5;

    public CouponDto.KpiResponse getKpi() {
        return couponMapper.selectKpi();
    }

    public CouponDto.PageResponse<CouponDto.ListItem> getCouponList(
            int page, String discountType, String status, String issuer, String keyword) {

        Map<String, Object> params = new HashMap<>();
        params.put("discountType", discountType);
        params.put("status", status);
        params.put("issuer", issuer);
        params.put("keyword", keyword);
        params.put("startRow", (page - 1) * PAGE_SIZE + 1);
        params.put("endRow", page * PAGE_SIZE);

        List<CouponDto.ListItem> list = couponMapper.selectCouponList(params);
        int totalCount = couponMapper.selectCouponCount(params);

        CouponDto.PageResponse<CouponDto.ListItem> res = new CouponDto.PageResponse<>();
        res.setList(list);
        res.setTotalCount(totalCount);
        res.setPagination(buildPagination(page, totalCount));
        return res;
    }

    public List<CouponDto.ListItem> getPendingList() {
        return couponMapper.selectPendingList();
    }

    @Transactional
    public void registerCoupon(CouponDto.SaveRequest req) {
        couponMapper.insertCoupon(req);

        if (req.getTargetList() != null && !req.getTargetList().isEmpty()) {
            Long couponId = couponMapper.selectCurrentCouponId();
            for (CouponTargetDto target : req.getTargetList()) {
                target.setCouponId(couponId);
                couponTargetMapper.insertCouponTarget(target);
            }
        }
    }

    @Transactional
    public void updateCoupon(Long couponId, CouponDto.SaveRequest req) {
        couponMapper.updateCoupon(couponId, req);

        couponTargetMapper.deleteCouponTargets(couponId);

        if (req.getTargetList() != null && !req.getTargetList().isEmpty()) {
            for (CouponTargetDto target : req.getTargetList()) {
                target.setCouponId(couponId);
                couponTargetMapper.insertCouponTarget(target);
            }
        }
    }

    public void reviewCoupon(Long couponId, CouponDto.ReviewRequest req) {
        couponMapper.updateCouponStatus(couponId, req.getResult(), req.getMemo());
    }

    public void deleteCoupons(List<Long> couponIds) {
        if (couponIds == null || couponIds.isEmpty()) return;

        for (Long id : couponIds) {
            couponTargetMapper.deleteCouponTargets(id);
            couponMapper.deleteCoupons(id);
        }
    }

    public CouponDto.PageResponse<CouponDto.IssuedItem> getIssuedList(
            int page, String status, String couponKeyword, String memberKeyword) {

        Map<String, Object> params = new HashMap<>();
        params.put("status", status);
        params.put("couponKeyword", couponKeyword);
        params.put("memberKeyword", memberKeyword);
        params.put("startRow", (page - 1) * PAGE_SIZE + 1);
        params.put("endRow", page * PAGE_SIZE);

        List<CouponDto.IssuedItem> list = couponMapper.selectIssuedList(params);
        int totalCount = couponMapper.selectIssuedCount(params);

        CouponDto.PageResponse<CouponDto.IssuedItem> res = new CouponDto.PageResponse<>();
        res.setList(list);
        res.setTotalCount(totalCount);
        res.setPagination(buildPagination(page, totalCount));
        return res;
    }

    public List<CouponDto.PartnerOption> getPartnerOptions() {
        return couponMapper.selectPartnerOptions();
    }

    @Override
    public CouponDto.DetailResponse getCouponById(Long couponId) {
        CouponDto.DetailResponse detail = couponMapper.selectCouponDetailById(couponId);
        if (detail != null) {
            detail.setTargetList(couponTargetMapper.selectCouponTargets(couponId));
        }
        return detail;
    }

    private CouponDto.PaginationInfo buildPagination(int page, int totalCount) {
        int totalPage = (int) Math.ceil((double) totalCount / PAGE_SIZE);
        int blockStart = ((page - 1) / BLOCK_SIZE) * BLOCK_SIZE + 1;
        int blockEnd = Math.min(blockStart + BLOCK_SIZE - 1, totalPage);

        List<Integer> pages = new ArrayList<>();
        for (int i = blockStart; i <= blockEnd; i++) pages.add(i);

        CouponDto.PaginationInfo info = new CouponDto.PaginationInfo();
        info.setPages(pages);
        info.setShowPrev(blockStart > 1);
        info.setShowNext(blockEnd < totalPage);
        info.setFirstPage(1);
        info.setLastPage(totalPage);
        info.setPrevBlockPage(blockStart - 1);
        info.setNextBlockPage(blockEnd + 1);
        return info;
    }
}