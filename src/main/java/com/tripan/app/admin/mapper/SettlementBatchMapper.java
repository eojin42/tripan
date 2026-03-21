package com.tripan.app.admin.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.tripan.app.admin.domain.dto.SettlementAggregateDto;

@Mapper
public interface SettlementBatchMapper {
	/**
     * 체크아웃 지났지만 아직 partner_settlement에 없는 예약들을
     * 파트너 + 정산월 단위로 집계해서 반환
     */
    List<SettlementAggregateDto> selectUnsettledAggregates(@Param("targetDate") String targetDate);
 
    /**
     * 해당 파트너 + 월 정산 레코드 존재 여부
     */
    boolean existsSettlement(@Param("partnerId")       Long   partnerId,
                             @Param("settlementMonth") String settlementMonth);
 
    /**
     * 신규 정산 INSERT
     */
    void insertSettlement(SettlementAggregateDto dto);
 
    /**
     * 기존 정산 금액 누적 UPDATE
     * (배치 재실행 시 중복 방지 - 기존 금액에 새 금액을 더함)
     */
    void updateSettlementAmount(SettlementAggregateDto dto);
}
