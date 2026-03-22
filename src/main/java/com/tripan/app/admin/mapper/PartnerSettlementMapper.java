package com.tripan.app.admin.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;

import com.tripan.app.admin.domain.dto.SettlementFilterDto;
import com.tripan.app.admin.domain.dto.SettlementManageDto;
import com.tripan.app.admin.domain.dto.SettlementOrderDto;

@Mapper
public interface PartnerSettlementMapper {
	 /** 파트너 월별 정산 요약 목록 */
    List<SettlementManageDto> selectSummaryList(SettlementFilterDto filter);

    /** 요약 목록 총 건수 (페이징용) */
    int selectSummaryCount(SettlementFilterDto filter);

    /** 특정 파트너의 숙소별 정산 상세 목록 */
    List<SettlementManageDto> selectDetailList(SettlementFilterDto filter);

    /** 특정 숙소의 예약 건별 라인 */
    List<SettlementOrderDto> selectOrderLines(Map<String, Object> params);

    /** 정산 승인 (숙소 단위 UPSERT) */
    void upsertSettlement(Map<String, Object> params);

    /** 파트너 단위 엑셀용 데이터 */
    List<SettlementOrderDto> selectExcelByPartner(SettlementFilterDto filter);

    /** 숙소 단위 엑셀용 데이터 */
    List<SettlementOrderDto> selectExcelByPlace(SettlementFilterDto filter);
}
