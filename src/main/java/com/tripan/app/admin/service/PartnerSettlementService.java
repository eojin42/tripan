package com.tripan.app.admin.service;

import java.util.List;

import com.tripan.app.admin.domain.dto.SettlementFilterDto;
import com.tripan.app.admin.domain.dto.SettlementManageDto;
import com.tripan.app.admin.domain.dto.SettlementOrderDto;

public interface PartnerSettlementService {
	public List<SettlementManageDto> getSummaryList(SettlementFilterDto filter);
	public int getSummaryCount(SettlementFilterDto filter);
	public List<SettlementManageDto> getDetailList(SettlementFilterDto filter);
	public List<SettlementOrderDto> getExcelRowsByPartner(SettlementFilterDto filter);
	public List<SettlementOrderDto> getExcelRowsByPlace(SettlementFilterDto filter);
	public void approvePlace(Long placeId, String settlementMonth, Long adminId);
	public void approveAllByPartner(Long memberId, String settlementMonth, Long adminId); 
	public void aggregateSettlement();
	public List<String> getAvailableMonths();
}
