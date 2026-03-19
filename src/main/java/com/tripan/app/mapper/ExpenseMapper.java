package com.tripan.app.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.tripan.app.domain.dto.ExpenseDto;
import com.tripan.app.domain.dto.SettlementDto;

/**
 * 통계/복잡 조회 전용 MyBatis Mapper
 * 단순 CRUD는 JPA Repository 사용
 * 집계, 정산 계산, 다중 조인 등 복잡한 쿼리만 여기서 처리
 */
@Mapper
public interface ExpenseMapper {

    /**
     * 여행 전체 지출 합계 (TripServiceImpl에서 사용)
     * getTripDetails → dto.setCurrentExpense() 에 사용됨
     */
    Double selectTotalExpenseAmount(@Param("tripId") Long tripId);

    /**
     * 여행 전체 지출 통계 (카테고리별 합계)
     */
    List<ExpenseDto.CategorySummary> selectCategorySummaryByTripId(
            @Param("tripId") Long tripId
    );

    /**
     * 멤버별 결제 합계 (누가 카드 긁었는지)
     * member 닉네임 조인 포함
     */
    List<ExpenseDto.MemberPaymentSummary> selectMemberPaymentSummaryByTripId(
            @Param("tripId") Long tripId
    );

    /**
     * 멤버별 부담 합계 (누가 얼마 내야 하는지)
     * expense_participant 기준, member 닉네임 조인 포함
     */
    List<ExpenseDto.MemberShareSummary> selectMemberShareSummaryByTripId(
            @Param("tripId") Long tripId
    );

    /**
     * 여행 지출 목록 (요약, 페이징 포함)
     * payer 닉네임 조인
     */
    List<ExpenseDto.SummaryResponse> selectExpenseSummaryListByTripId(
            @Param("tripId") Long tripId,
            @Param("offset") int offset,
            @Param("limit") int limit
    );

    /**
     * 지출 상세 조회 (payer 닉네임 포함)
     */
    ExpenseDto.DetailResponse selectExpenseDetailById(
            @Param("expenseId") Long expenseId
    );

    /**
     * 지출별 분담자 목록 조회 (멤버 닉네임 조인)
     */
    List<ExpenseDto.ParticipantResponse> selectParticipantsByExpenseId(
            @Param("expenseId") Long expenseId
    );

    /**
     * 정산 계산을 위한 핵심 쿼리
     * 여행 내 각 멤버의 (총 결제액 - 총 부담액) = balance 계산
     * 반환: memberId, nickname, paidAmount, shareAmount, balance
     */
    List<ExpenseDto.MemberShareSummary> calculateBalancesByTripId(
            @Param("tripId") Long tripId
    );

    /**
     * 특정 여행의 정산 목록 조회 (멤버 닉네임 포함)
     */
    List<SettlementDto.Response> selectSettlementsByTripId(
            @Param("tripId") Long tripId
    );

    /**
     * 내가 보내야 할 정산 / 받아야 할 정산 조회
     */
    List<SettlementDto.Response> selectSettlementsByTripIdAndMember(
            @Param("tripId") Long tripId,
            @Param("memberId") Long memberId
    );
}
