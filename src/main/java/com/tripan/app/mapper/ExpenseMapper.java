package com.tripan.app.mapper;

import java.util.List;
import java.util.Map;

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

    /** 여행 전체 지출 합계 */
    Double selectTotalExpenseAmount(@Param("tripId") Long tripId);

    /** 카테고리별 지출 합계 */
    List<ExpenseDto.CategorySummary> selectCategorySummaryByTripId(
            @Param("tripId") Long tripId);

    /** 멤버별 결제 합계 */
    List<ExpenseDto.MemberPaymentSummary> selectMemberPaymentSummaryByTripId(
            @Param("tripId") Long tripId);

    /** 멤버별 부담 합계 */
    List<ExpenseDto.MemberShareSummary> selectMemberShareSummaryByTripId(
            @Param("tripId") Long tripId);

    /** 지출 목록 요약 (페이징, settleStatus/settledBatchId 포함) */
    List<ExpenseDto.SummaryResponse> selectExpenseSummaryListByTripId(
            @Param("tripId") Long tripId,
            @Param("offset") int offset,
            @Param("limit")  int limit);

    /** 지출 상세 단건 */
    ExpenseDto.DetailResponse selectExpenseDetailById(
            @Param("expenseId") Long expenseId);

    /** 지출별 분담자 목록 */
    List<ExpenseDto.ParticipantResponse> selectParticipantsByExpenseId(
            @Param("expenseId") Long expenseId);

    /**
     * 전체 balance 계산 (기존 — 홈탭 통계용으로만 유지)
     */
    List<ExpenseDto.MemberShareSummary> calculateBalancesByTripId(
            @Param("tripId") Long tripId);

    /**
     * ★ 재정산용 balance 계산
     * COMPLETED batch에 연결된 expense를 제외하고 계산
     */
    List<ExpenseDto.MemberShareSummary> calculateBalancesForUnlinkedExpenses(
            @Param("tripId") Long tripId);

    /** 정산 목록 조회 (멤버 닉네임 포함) */
    List<SettlementDto.Response> selectSettlementsByTripId(
            @Param("tripId") Long tripId);

    /** 내가 관련된 정산 조회 */
    List<SettlementDto.Response> selectSettlementsByTripIdAndMember(
            @Param("tripId")   Long tripId,
            @Param("memberId") Long memberId);

    /** 단건 정산 요청 INSERT */
    int insertSingleSettlement(SettlementDto.SingleRequest req);

    /** 기존 REQUESTED/PENDING 정산 amount 업데이트 (새 지출 추가 후 재계산용) */
    int updateSingleSettlementAmount(SettlementDto.SingleRequest req);

    /**
     * ★ 단건 settlement_id 기준 amount 업데이트
     * 기존 updateSingleSettlementAmount는 (tripId, toMemberId, fromMemberId) 조합으로
     * 전체 미완료 정산을 덮어써서 "1건 눌렀는데 전부 처리" 버그 발생 → 이 메서드로 대체
     */
    int updateSettlementById(@Param("settlementId") Long settlementId,
                             @Param("amount") java.math.BigDecimal amount);

    /** 중복 요청 방지 체크 */
    int countActiveSettlement(@Param("tripId")       Long tripId,
                              @Param("toMemberId")   Long toMemberId,
                              @Param("fromMemberId") Long fromMemberId);

    /** 여행 멤버 ID 목록 (알림 발송용) */
    List<Map<String, Object>> selectTripMemberIds(@Param("tripId") Long tripId);

    /** 알림 INSERT */
    int insertTripNotification(@Param("tripId")     Long tripId,
                               @Param("receiverId") Long receiverId,
                               @Param("senderId")   Long senderId,
                               @Param("message")    String message,
                               @Param("type")       String type);

    /** 내가 결제한 카테고리별 합계 */
    List<ExpenseDto.CategorySummary> selectMyCategorySummaryByTripId(
            @Param("tripId")   Long tripId,
            @Param("memberId") Long memberId);

    /** 나에게 온 정산 요청 건수 */
    int countIncomingSettlementRequests(
            @Param("tripId")   Long tripId,
            @Param("memberId") Long memberId);

    /** 내가 최근 결제한 지출 */
    List<ExpenseDto.SummaryResponse> selectMyRecentExpenses(
            @Param("tripId")   Long tripId,
            @Param("memberId") Long memberId,
            @Param("limit")    int limit);

    Long selectNextBatchId();

	 // pair에 해당하는 미정산 expense ID 목록 조회
	 List<Long> selectPairExpenseIds(
	     @Param("tripId") Long tripId,
	     @Param("toMemberId") Long toMemberId,
	     @Param("fromMemberId") Long fromMemberId
	 );
    
    // ════════════════════════════════════════════════════════
    //  settlement_expense_link 관련 (★ 신규)
    // ════════════════════════════════════════════════════════

    /** settlement_expense_link batch INSERT */
    int insertSettlementExpenseLinks(List<Map<String, Object>> list);

    /**
     * COMPLETED batch에 연결된 expense_id 목록
     * createSettlements() 에서 이번 batch 대상 산출에 사용
     */
    List<Long> selectSettledExpenseIdsByTripId(@Param("tripId") Long tripId);

    // ════════════════════════════════════════════════════════
    //  정산 완료 상세보기 (★ 신규)
    // ════════════════════════════════════════════════════════

    /** batch의 settlement(transfer) 목록 */
    List<SettlementDto.Response> selectBatchTransfers(
            @Param("tripId")  Long tripId,
            @Param("batchId") Long batchId);

    /** batch에 연결된 expense 목록 */
    List<ExpenseDto.DetailResponse> selectExpensesByBatchId(
            @Param("tripId")  Long tripId,
            @Param("batchId") Long batchId);

    /** batch 멤버별 결제/부담/잔액 요약 (계산 근거용) */
    List<ExpenseDto.MemberShareSummary> selectBatchMemberSummary(
            @Param("tripId")  Long tripId,
            @Param("batchId") Long batchId);
    
    List<Long> selectMultiParticipantExpenseIds(@Param("tripId") Long tripId);
}
