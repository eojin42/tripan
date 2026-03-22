package com.tripan.app.admin.scheduler;

import com.tripan.app.admin.service.PartnerManageService;
import com.tripan.app.admin.service.PartnerSettlementService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
public class AdminScheduler {

    private final PartnerManageService partnerService;
    private final PartnerSettlementService settlementService; 

    /**
     * 매일 자정 실행 — 계약 만료된 파트너를 SUSPENDED로 일괄 처리
     */
    @Scheduled(cron = "0 0 0 * * *")
    public void expireContracts() {
        log.info("[스케줄러] 계약 만료 파트너 정지 처리 시작");
        partnerService.expireContracts();
        log.info("[스케줄러] 계약 만료 파트너 정지 처리 완료");
    }
    
    /**
     * 매일 새벽 2시 실행 — 체크아웃 완료된 예약 정산 집계
     */
    @Scheduled(cron = "0 0 2 * * *")
    public void aggregateSettlement() {
    	log.info("[스케줄러] 월별 정산 집계 시작");
        settlementService.aggregateSettlement();
        log.info("[스케줄러] 월별 정산 집계 완료");
    }
}
