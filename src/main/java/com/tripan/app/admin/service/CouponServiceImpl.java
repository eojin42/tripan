package com.tripan.app.admin.service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import com.tripan.app.admin.domain.dto.CouponDto;
import com.tripan.app.admin.domain.dto.CouponTargetDto;
import com.tripan.app.admin.mapper.CouponManageMapper;
import com.tripan.app.admin.mapper.CouponTargetMapper;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class CouponServiceImpl implements CouponService {

	private final CouponManageMapper couponMapper;
    private final CouponTargetMapper couponTargetMapper;

    private static final int PAGE_SIZE = 10;
    private static final int BLOCK_SIZE = 5;

    @Override
    public CouponDto.KpiResponse getKpi() {
        return couponMapper.selectKpi();
    }

    @Override
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

    @Override
    public List<CouponDto.ListItem> getPendingList() {
        return couponMapper.selectPendingList();
    }

    @Override
    @Transactional
    public void registerCoupon(CouponDto.SaveRequest req) {
        couponMapper.insertCoupon(req);
        Long couponId = couponMapper.selectCurrentCouponId();
        saveTargets(couponId, req.getTargetList());
    }

    @Override
    @Transactional
    public void updateCoupon(Long couponId, CouponDto.SaveRequest req) {
        couponMapper.updateCoupon(couponId, req);
        couponTargetMapper.deleteCouponTargets(couponId);
        saveTargets(couponId, req.getTargetList());
    }

    @Override
    public void reviewCoupon(Long couponId, CouponDto.ReviewRequest req) {
        couponMapper.updateCouponStatus(couponId, req.getResult(), req.getMemo());
    }

    @Override
    @Transactional
    public void deleteCoupons(List<Long> couponIds) {
        if (couponIds == null || couponIds.isEmpty()) {
            return;
        }

        for (Long id : couponIds) {
            couponTargetMapper.deleteCouponTargets(id);
            couponMapper.deleteCoupons(id);
        }
    }

    @Override
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

    @Override
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

    private void saveTargets(Long couponId, List<CouponTargetDto> targetList) {
        if (targetList == null || targetList.isEmpty()) {
            return;
        }

        for (CouponTargetDto target : targetList) {
            target.setCouponId(couponId);
            normalizeTarget(target);
            couponTargetMapper.insertCouponTarget(target);
        }
    }

    private void normalizeTarget(CouponTargetDto target) {
        if (target.getIsExclude() == null || target.getIsExclude().isBlank()) {
            target.setIsExclude("N");
        }

        if (target.getTargetType() == null) {
            return;
        }

        switch (target.getTargetType()) {
            case "ACC_TYPE":
                target.setPlaceId(null);
                break;
            case "ACCOMMODATION":
                if (target.getPlaceId() != null && (target.getTargetValue() == null || target.getTargetValue().isBlank())) {
                    target.setTargetValue(String.valueOf(target.getPlaceId()));
                }
                break;
            case "ROOM":
                // room 은 targetValue(room_id) 유지, 숙소 단위 조회용으로 placeId 보조 저장
                break;
            default:
                break;
        }
    }

    private CouponDto.PaginationInfo buildPagination(int page, int totalCount) {
        int totalPage = (int) Math.ceil((double) totalCount / PAGE_SIZE);
        int blockStart = ((page - 1) / BLOCK_SIZE) * BLOCK_SIZE + 1;
        int blockEnd = Math.min(blockStart + BLOCK_SIZE - 1, totalPage);

        List<Integer> pages = new ArrayList<>();
        for (int i = blockStart; i <= blockEnd; i++) {
            pages.add(i);
        }

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
    
    @Override
    @Transactional
    public void revokeCoupon(Long memberCouponId) {
        couponMapper.revokeMemberCoupon(memberCouponId);
    }
    
    @Override
    @Transactional
    public void grantCoupon(CouponDto.GrantRequest req) {
        Long memberId = couponMapper.selectMemberIdByLoginId(req.getLoginId());
        if (memberId == null) throw new ResponseStatusException(HttpStatus.NOT_FOUND, "존재하지 않는 회원입니다.");
        couponMapper.insertMemberCoupon(memberId, req.getCouponId());
    }

}