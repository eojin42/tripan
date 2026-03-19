package com.tripan.app.admin.scheduler;

import com.tripan.app.admin.service.PartnerManageService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
public class PartnerContractScheduler {

    private final PartnerManageService partnerService;

    /**
     * 매일 자정 실행 — 계약 만료된 파트너를 SUSPENDED로 일괄 처리
     */
    @Scheduled(cron = "0 0 0 * * *")
    public void expireContracts() {
        log.info("[스케줄러] 계약 만료 파트너 정지 처리 시작");
        partnerService.expireContracts();
        log.info("[스케줄러] 계약 만료 파트너 정지 처리 완료");
    }
}
