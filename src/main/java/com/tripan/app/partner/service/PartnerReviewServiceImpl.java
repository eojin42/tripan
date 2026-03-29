package com.tripan.app.partner.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.tripan.app.partner.domain.dto.PartnerReviewDto;
import com.tripan.app.partner.mapper.PartnerReviewMapper;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class PartnerReviewServiceImpl implements PartnerReviewService {

    private final PartnerReviewMapper partnerReviewMapper;


    @Override
    public Map<String, Object> getPagedReviewList(Map<String, Object> searchParams) {
        int page = Integer.parseInt(searchParams.get("page").toString());
        int limit = Integer.parseInt(searchParams.get("limit").toString());
        
        int offset = (page - 1) * limit;
        searchParams.put("offset", offset); 
        
        List<PartnerReviewDto> reviewList = partnerReviewMapper.selectReviewListForPartner(searchParams);
        int totalCount = partnerReviewMapper.countReviewListForPartner(searchParams);
        
        int totalPages = (int) Math.ceil((double) totalCount / limit);
        if(totalPages == 0) totalPages = 1; 

        Map<String, Object> resultMap = new HashMap<>();
        resultMap.put("reviewList", reviewList);
        resultMap.put("totalPages", totalPages);
        
        return resultMap;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteReview(Long reviewId) throws Exception {
        partnerReviewMapper.deleteReviewImages(reviewId);
        partnerReviewMapper.deleteReview(reviewId);
    }
}