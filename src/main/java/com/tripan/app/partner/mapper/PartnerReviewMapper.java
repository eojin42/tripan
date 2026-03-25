package com.tripan.app.partner.mapper;

import java.util.List;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import com.tripan.app.partner.domain.dto.PartnerReviewDto;

@Mapper
public interface PartnerReviewMapper {
    
    List<PartnerReviewDto> selectReviewListForPartner(
        @Param("placeId") Long placeId,
        @Param("startDate") String startDate,
        @Param("endDate") String endDate,
        @Param("roomId") String roomId,
        @Param("rating") String rating,
        @Param("keyword") String keyword
    );

    void deleteReviewImages(@Param("reviewId") Long reviewId);

    void deleteReview(@Param("reviewId") Long reviewId);
}