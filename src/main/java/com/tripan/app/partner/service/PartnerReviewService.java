package com.tripan.app.partner.service;

import java.util.List;
import com.tripan.app.partner.domain.dto.PartnerReviewDto;

public interface PartnerReviewService {
    List<PartnerReviewDto> getReviewList(Long placeId, String startDate, String endDate, String roomId, String rating, String keyword);
    
    void deleteReview(Long reviewId) throws Exception;
}