package com.tripan.app.partner.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.tripan.app.partner.domain.dto.PartnerReviewDto;

@Mapper
public interface PartnerReviewMapper {

    List<PartnerReviewDto> selectReviewListForPartner(Map<String, Object> params);

    int countReviewListForPartner(Map<String, Object> params);

    void deleteReviewImages(@Param("reviewId") Long reviewId);

    void deleteReview(@Param("reviewId") Long reviewId);
    
}