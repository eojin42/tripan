package com.tripan.app.admin.service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;

import com.tripan.app.admin.domain.dto.CouponDto;
import com.tripan.app.admin.domain.dto.CouponDto.ListItem;
import com.tripan.app.admin.mapper.CouponMapper;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class CouponServiceImpl implements CouponService{

	private final CouponMapper couponMapper;

    private static final int PAGE_SIZE = 10;  // 한 페이지 row 수
    private static final int BLOCK_SIZE = 5;  // 페이지 블록 수

    /* ── KPI ── */
    public CouponDto.KpiResponse getKpi() {
        return couponMapper.selectKpi();
    }

    /* ── 쿠폰 목록 ── */
    public CouponDto.PageResponse<CouponDto.ListItem> getCouponList(
            int page, String discountType, String status, String issuer, String keyword) {

        Map<String, Object> params = new HashMap<>();
        params.put("discountType", discountType);
        params.put("status",       status);
        params.put("issuer",       issuer);
        params.put("keyword",      keyword);
        params.put("startRow",     (page - 1) * PAGE_SIZE + 1);
        params.put("endRow",       page * PAGE_SIZE);

        List<CouponDto.ListItem> list  = couponMapper.selectCouponList(params);
        int totalCount                 = couponMapper.selectCouponCount(params);

        CouponDto.PageResponse<CouponDto.ListItem> res = new CouponDto.PageResponse<>();
        res.setList(list);
        res.setTotalCount(totalCount);
        res.setPagination(buildPagination(page, totalCount));
        return res;
    }

    /* ── 승인 대기 목록 ── */
    public List<CouponDto.ListItem> getPendingList() {
        return couponMapper.selectPendingList();
    }

    /* ── 쿠폰 등록 (관리자 직접) ── */
    public void registerCoupon(CouponDto.SaveRequest req) {
        couponMapper.insertCoupon(req);
    }

    /* ── 쿠폰 수정 ── */
    public void updateCoupon(Long couponId, CouponDto.SaveRequest req) {
        couponMapper.updateCoupon(couponId, req);
    }

    /* ── 승인/반려 ── */
    public void reviewCoupon(Long couponId, CouponDto.ReviewRequest req) {
        couponMapper.updateCouponStatus(couponId, req.getResult(), req.getMemo());
    }

    /* ── 삭제 ── */
    public void deleteCoupons(List<Long> couponIds) {
        if (couponIds == null || couponIds.isEmpty()) return;
        
        for(Long id : couponIds) {
        	couponMapper.deleteCoupons(id);
        }
    }

    /* ── 회원 발급 현황 ── */
    public CouponDto.PageResponse<CouponDto.IssuedItem> getIssuedList(
            int page, String status, String couponKeyword, String memberKeyword) {

        Map<String, Object> params = new HashMap<>();
        params.put("status",        status);
        params.put("couponKeyword", couponKeyword);
        params.put("memberKeyword", memberKeyword);
        params.put("startRow",      (page - 1) * PAGE_SIZE + 1);
        params.put("endRow",        page * PAGE_SIZE);

        List<CouponDto.IssuedItem> list = couponMapper.selectIssuedList(params);
        int totalCount                  = couponMapper.selectIssuedCount(params);

        CouponDto.PageResponse<CouponDto.IssuedItem> res = new CouponDto.PageResponse<>();
        res.setList(list);
        res.setTotalCount(totalCount);
        res.setPagination(buildPagination(page, totalCount));
        return res;
    }

    /* ── 파트너 옵션 ── */
    public List<CouponDto.PartnerOption> getPartnerOptions() {
        return couponMapper.selectPartnerOptions();
    }

    /* ── 페이지네이션 빌더 ── */
    private CouponDto.PaginationInfo buildPagination(int page, int totalCount) {
        int totalPage    = (int) Math.ceil((double) totalCount / PAGE_SIZE);
        int blockStart   = ((page - 1) / BLOCK_SIZE) * BLOCK_SIZE + 1;
        int blockEnd     = Math.min(blockStart + BLOCK_SIZE - 1, totalPage);

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

	@Override
	public ListItem getCouponById(Long couponId) {
		return couponMapper.selectCouponById(couponId);
	}
}
