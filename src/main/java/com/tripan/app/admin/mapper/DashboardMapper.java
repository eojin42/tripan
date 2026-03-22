package com.tripan.app.admin.mapper;

import com.tripan.app.admin.domain.dto.DashboardDto;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface DashboardMapper {

    /** 최근 7일 일별 예약 추이 */
    List<DashboardDto.DailyOrderDto> selectDailyOrders();

    /** 실시간 숙소 랭킹 TOP 5 (최근 30일 예약 건수) */
    List<DashboardDto.AccomRankDto> selectAccomRanking();

    /** 지역 랭킹 TOP 5 (전체 일정 생성 수) */
    List<DashboardDto.RegionRankDto> selectRegionRanking();

    /** 미답변 CS 채팅 목록 (WAITING 상태) */
    List<DashboardDto.UnAnsweredChatDto> selectUnAnsweredChats();

    /** 입점 승인 대기 파트너 목록 */
    List<DashboardDto.PendingPartnerDto> selectPendingPartners();

    /** 신고 상위 유저 TOP 10 */
    List<DashboardDto.TopReportedDto> selectTopReported();
}