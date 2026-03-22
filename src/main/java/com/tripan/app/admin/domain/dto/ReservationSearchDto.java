package com.tripan.app.admin.domain.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ReservationSearchDto {
	private String startDate;
    private String endDate;
    private String status;
    private String paymentStatus;
    private String partnerName;
    private String placeName;
    private String keywordType;
    private String keyword;
 
    private int page = 1;
    private int size = 10;
 
    public int getOffset() {
        return (page - 1) * size;
    }
}
