package com.tripan.app.admin.domain.dto;

import lombok.Data;

/**
 * 정산 검색 필터 파라미터
 */
@Data
public class SettlementFilterDto {

    private String settlementMonth; // YYYY-MM, null이면 전체
    private String status;          // PENDING / PARTIAL / DONE / null(전체)
    private String region;          // 지역, null이면 전체
    private String keyword;         // 파트너명 or 로그인ID

    // 엑셀 다운로드 대상 지정
    private Long   memberId;        // 특정 파트너만 (파트너 단위 엑셀)
    private Long   placeId;         // 특정 숙소만  (숙소 단위 엑셀)

    // 페이징 (목록)
    private int page   = 1;
    private int size   = 20;

    public int getOffset() {
        return (page - 1) * size;
    }
}
