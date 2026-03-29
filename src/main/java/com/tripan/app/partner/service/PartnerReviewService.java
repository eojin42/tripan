package com.tripan.app.partner.service;

import java.util.Map;

public interface PartnerReviewService {
    
    Map<String, Object> getPagedReviewList(Map<String, Object> searchParams);
    
    void deleteReview(Long reviewId) throws Exception;
}