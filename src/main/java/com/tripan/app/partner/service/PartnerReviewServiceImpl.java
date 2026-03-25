package com.tripan.app.partner.service;

import java.util.List;
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
    public List<PartnerReviewDto> getReviewList(Long placeId, String startDate, String endDate, String roomId, String rating, String keyword) {
        return partnerReviewMapper.selectReviewListForPartner(placeId, startDate, endDate, roomId, rating, keyword);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteReview(Long reviewId) throws Exception {
    	
        partnerReviewMapper.deleteReviewImages(reviewId);
        partnerReviewMapper.deleteReview(reviewId);
        
    }
}