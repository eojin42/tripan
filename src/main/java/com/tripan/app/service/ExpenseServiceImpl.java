package com.tripan.app.service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.tripan.app.domain.dto.ExpenseDto;
import com.tripan.app.domain.dto.SettlementDto;
import com.tripan.app.mapper.ExpenseMapper;
import com.tripan.app.trip.domain.entity.Expense;
import com.tripan.app.trip.domain.entity.ExpenseParticipant;
import com.tripan.app.trip.domain.entity.Settlement;
import com.tripan.app.trip.repository.ExpenseParticipantRepository;
import com.tripan.app.trip.repository.ExpenseRepository;
import com.tripan.app.trip.repository.SettlementRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ExpenseServiceImpl implements ExpenseService {

    private final ExpenseRepository expenseRepository;
    private final ExpenseParticipantRepository participantRepository;
    private final SettlementRepository settlementRepository;
    private final ExpenseMapper expenseMapper;

    // ════════════════════════════════════════════════════════
    //  지출 CRUD
    // ════════════════════════════════════════════════════════

    @Override
    @Transactional
    public ExpenseDto.DetailResponse createExpense(ExpenseDto.CreateRequest req) {

        validateParticipantsTotal(req.getAmount(), req.getParticipants());

        Expense expense = Expense.builder()
                .tripId(req.getTripId())
                .payerId(req.getPayerId())
                .category(req.getCategory())
                .amount(req.getAmount())
                .description(req.getDescription())
                .expenseDate(req.getExpenseDate())
                .receiptUrl(req.getReceiptUrl())
                .paymentType(req.getPaymentType())
                .memo(req.getMemo())
                .build();

        for (ExpenseDto.ParticipantRequest p : req.getParticipants()) {
            expense.getParticipants().add(
                    ExpenseParticipant.builder()
                            .expense(expense)
                            .memberId(p.getMemberId())
                            .nickname(p.getNickname())
                            .shareAmount(p.getShareAmount())
                            .build()
            );
        }

        Expense saved = expenseRepository.save(expense);
        return expenseMapper.selectExpenseDetailById(saved.getExpenseId());
    }

    @Override
    @Transactional
    public ExpenseDto.DetailResponse updateExpense(Long expenseId, ExpenseDto.UpdateRequest req) {

        Expense expense = expenseRepository.findById(expenseId)
                .orElseThrow(() -> new IllegalArgumentException("지출 정보를 찾을 수 없습니다. id=" + expenseId));

        validateParticipantsTotal(req.getAmount(), req.getParticipants());

        expense.setCategory(req.getCategory());
        expense.setAmount(req.getAmount());
        expense.setDescription(req.getDescription());
        expense.setExpenseDate(req.getExpenseDate());
        expense.setReceiptUrl(req.getReceiptUrl());
        expense.setPaymentType(req.getPaymentType());
        expense.setMemo(req.getMemo());

        expense.getParticipants().clear();
        for (ExpenseDto.ParticipantRequest p : req.getParticipants()) {
            expense.getParticipants().add(
                    ExpenseParticipant.builder()
                            .expense(expense)
                            .memberId(p.getMemberId())
                            .nickname(p.getNickname())
                            .shareAmount(p.getShareAmount())
                            .build()
            );
        }

        return expenseMapper.selectExpenseDetailById(expenseId);
    }

    @Override
    @Transactional
    public void deleteExpense(Long expenseId) {
        Expense expense = expenseRepository.findById(expenseId)
                .orElseThrow(() -> new IllegalArgumentException("지출 정보를 찾을 수 없습니다. id=" + expenseId));
        expenseRepository.delete(expense);
    }

    // ════════════════════════════════════════════════════════
    //  지출 조회
    // ════════════════════════════════════════════════════════

    @Override
    public ExpenseDto.DetailResponse getExpenseDetail(Long expenseId) {
        ExpenseDto.DetailResponse detail = expenseMapper.selectExpenseDetailById(expenseId);
        if (detail == null) throw new IllegalArgumentException("지출 정보를 찾을 수 없습니다. id=" + expenseId);
        detail.setParticipants(expenseMapper.selectParticipantsByExpenseId(expenseId));
        return detail;
    }

    @Override
    public List<ExpenseDto.SummaryResponse> getExpenseList(Long tripId, int page, int size) {
        int offset = (page - 1) * size;
        return expenseMapper.selectExpenseSummaryListByTripId(tripId, offset, size);
    }

    @Override
    public ExpenseDto.TripSummaryResponse getTripExpenseSummary(Long tripId) {
        BigDecimal totalAmount = expenseRepository.sumAmountByTripId(tripId);
        List<ExpenseDto.CategorySummary> categories = expenseMapper.selectCategorySummaryByTripId(tripId);
        List<ExpenseDto.MemberPaymentSummary> payments = expenseMapper.selectMemberPaymentSummaryByTripId(tripId);
        List<ExpenseDto.MemberShareSummary> shares = expenseMapper.calculateBalancesByTripId(tripId);

        return ExpenseDto.TripSummaryResponse.builder()
                .tripId(tripId)
                .totalAmount(totalAmount)
                .categoryBreakdown(categories)
                .memberPayments(payments)
                .memberShares(shares)
                .build();
    }

    // ════════════════════════════════════════════════════════
    //  정산 계산 및 생성
    // ════════════════════════════════════════════════════════

    @Override
    public SettlementDto.PreviewResponse previewSettlement(Long tripId) {
        // 미리보기는 완료 정산 차감 적용 (실제 남은 정산만 보여줌)
        List<ExpenseDto.MemberShareSummary> rawBalances = expenseMapper.calculateBalancesByTripId(tripId);
        List<Settlement> completed = settlementRepository.findByTripIdAndStatus(tripId, "COMPLETED");
        List<ExpenseDto.MemberShareSummary> adjusted = applyCompletedSettlements(rawBalances, completed);
        List<SettlementDto.SettlementDetail> details = calculateOptimalSettlements(adjusted);

        return SettlementDto.PreviewResponse.builder()
                .tripId(tripId)
                .details(details)
                .build();
    }

    /**
     * 정산 일괄 생성
     *
     * ★ Bug Fix: 재정산 로직 수정
     * - 기존: deleteByTripId() → 완료 이력까지 전부 삭제 후 전체 재계산 (❌)
     * - 수정:
     *   1) deleteNonCompletedByTripId() → COMPLETED 정산은 이력으로 보존
     *   2) 완료된 정산 금액을 expense 기반 balance에서 차감
     *   3) 차감된 잔여 balance로만 새 정산 생성
     *
     * [예시]
     *   - A → B ₩30,000 COMPLETED (이미 송금 완료)
     *   - 이후 새 공용 지출 ₩20,000 발생 (A 결제, A/B 반반)
     *   → B가 A에게 갚아야 할 잔여 = ₩10,000 (새 건)
     *   → ₩30,000 완료 건은 완료 이력에 그대로 남음
     */
    @Override
    @Transactional
    public SettlementDto.TripSettlementResponse createSettlements(
            SettlementDto.CreateBatchRequest req, Long requestMemberId) {

        Long tripId = req.getTripId();

        // ① COMPLETED 제외하고 PENDING/REQUESTED 만 삭제
        settlementRepository.deleteNonCompletedByTripId(tripId);

        // ② expense 기반 raw balance 계산
        List<ExpenseDto.MemberShareSummary> rawBalances = expenseMapper.calculateBalancesByTripId(tripId);

        // ③ 이미 완료된 정산 금액 차감 → 진짜 남은 미정산 금액 계산
        List<Settlement> completedSettlements = settlementRepository.findByTripIdAndStatus(tripId, "COMPLETED");
        List<ExpenseDto.MemberShareSummary> adjustedBalances = applyCompletedSettlements(rawBalances, completedSettlements);

        // ④ 잔여 balance로 최적 정산 경로 계산
        List<SettlementDto.SettlementDetail> details = calculateOptimalSettlements(adjustedBalances);

        // 모든 정산이 완료된 경우 빈 결과 반환
        if (details.isEmpty()) {
            return getTripSettlements(tripId, requestMemberId);
        }

        // ⑤ batch_id 결정 후 저장
        Long batchId = req.getBatchId() != null
                ? req.getBatchId()
                : settlementRepository.generateNextBatchId();

        List<Settlement> settlements = details.stream()
                .map(d -> Settlement.builder()
                        .tripId(tripId)
                        .fromMemberId(d.getFromMemberId())
                        .toMemberId(d.getToMemberId())
                        .amount(d.getAmount())
                        .status("PENDING")
                        .batchId(batchId)
                        .build())
                .collect(Collectors.toList());

        settlementRepository.saveAll(settlements);

        return getTripSettlements(tripId, requestMemberId);
    }

    @Override
    @Transactional
    public void completeSettlements(SettlementDto.CompleteRequest req) {
        for (Long id : req.getSettlementIds()) {
            settlementRepository.findById(id).ifPresent(s -> {
                s.setStatus("COMPLETED");
                s.setSettledAt(LocalDateTime.now());
            });
        }
    }

    @Override
    @Transactional
    public void deleteSettlement(Long settlementId) {
        settlementRepository.findById(settlementId).ifPresent(settlementRepository::delete);
    }

    @Override
    public SettlementDto.TripSettlementResponse getTripSettlements(Long tripId, Long memberId) {
        List<SettlementDto.Response> all = expenseMapper.selectSettlementsByTripId(tripId);

        BigDecimal toReceive = settlementRepository.sumAmountToReceive(tripId, memberId);
        BigDecimal toSend    = settlementRepository.sumAmountToSend(tripId, memberId);

        long pending   = all.stream().filter(s -> "PENDING".equals(s.getStatus())).count();
        long completed = all.stream().filter(s -> "COMPLETED".equals(s.getStatus())).count();

        return SettlementDto.TripSettlementResponse.builder()
                .tripId(tripId)
                .settlements(all)
                .totalToReceive(toReceive)
                .totalToSend(toSend)
                .pendingCount((int) pending)
                .completedCount((int) completed)
                .build();
    }

    // ════════════════════════════════════════════════════════
    //  Private 헬퍼
    // ════════════════════════════════════════════════════════

    /**
     * ★ 신규: 완료된 정산을 balance에서 차감
     *
     * 완료된 settlement는 실제 송금이 끝난 것이므로:
     * - fromMemberId (돈 보낸 사람): 그만큼 부채 갚음 → balance 증가 (덜 빚진 것)
     * - toMemberId   (돈 받은 사람): 그만큼 채권 회수됨 → balance 감소 (덜 받을 것)
     *
     * @param rawBalances       expense 기반 순수 balance 목록
     * @param completedList     이미 COMPLETED된 settlement 목록
     * @return 완료 정산 차감 후 잔여 balance 목록
     */
    /**
     * 완료된 정산을 balance에서 차감
     * ★ setter 방식 사용 — @Builder 없이 @Getter @Setter @NoArgsConstructor 구조에서도 동작
     */
    private List<ExpenseDto.MemberShareSummary> applyCompletedSettlements(
            List<ExpenseDto.MemberShareSummary> rawBalances,
            List<Settlement> completedList) {

        if (completedList == null || completedList.isEmpty()) {
            return rawBalances;
        }

        // memberId → balance 맵 구성
        Map<Long, BigDecimal> balanceMap = new HashMap<>();
        Map<Long, String>     nickMap    = new HashMap<>();

        for (ExpenseDto.MemberShareSummary b : rawBalances) {
            balanceMap.put(b.getMemberId(),
                b.getBalance() != null ? b.getBalance() : BigDecimal.ZERO);
            nickMap.put(b.getMemberId(), b.getNickname());
        }

        // 완료된 정산 차감
        for (Settlement s : completedList) {
            Long       from = s.getFromMemberId();
            Long       to   = s.getToMemberId();
            BigDecimal amt  = s.getAmount() != null ? s.getAmount() : BigDecimal.ZERO;
            // 이미 보냈음 → 부채 줄어듦 (balance +)
            if (from != null) balanceMap.merge(from, amt,           BigDecimal::add);
            // 이미 받았음 → 채권 줄어듦 (balance -)
            if (to   != null) balanceMap.merge(to,   amt.negate(),  BigDecimal::add);
        }

        // ★ stream().map() + builder() 대신 명시적 for-loop + setter 사용
        //   → "Cannot infer type argument(s) for map()" 컴파일 에러 방지
        List<ExpenseDto.MemberShareSummary> result = new ArrayList<>();
        for (Map.Entry<Long, BigDecimal> entry : balanceMap.entrySet()) {
            Long       mid    = entry.getKey();
            BigDecimal newBal = entry.getValue();
            ExpenseDto.MemberShareSummary item = new ExpenseDto.MemberShareSummary();
            item.setMemberId(mid);
            item.setNickname(nickMap.getOrDefault(mid, ""));
            item.setBalance(newBal);
            item.setShareAmount(BigDecimal.ZERO);
            // paidAmount 필드 없음 (MemberShareSummary에 미정의) → 제거
            result.add(item);
        }
        return result;
    }

    private void validateParticipantsTotal(BigDecimal totalAmount,
                                           List<ExpenseDto.ParticipantRequest> participants) {
        if (participants == null || participants.isEmpty()) {
            throw new IllegalArgumentException("분담 참여자는 1명 이상이어야 합니다.");
        }
        BigDecimal participantTotal = participants.stream()
                .map(ExpenseDto.ParticipantRequest::getShareAmount)
                .filter(a -> a != null)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        if (participantTotal.compareTo(totalAmount) != 0) {
            throw new IllegalArgumentException(
                    String.format("분담 금액 합계(%s)가 총 결제 금액(%s)과 일치하지 않습니다.",
                            participantTotal, totalAmount));
        }
    }

    /**
     * 최적 정산 계산 알고리즘 (최소 이체 횟수, greedy)
     * balance > 0 : 받을 사람 (채권자)
     * balance < 0 : 보낼 사람 (채무자)
     */
    private List<SettlementDto.SettlementDetail> calculateOptimalSettlements(
            List<ExpenseDto.MemberShareSummary> balances) {

        List<SettlementDto.SettlementDetail> result = new ArrayList<>();

        LinkedList<long[]> creditors = new LinkedList<>();
        LinkedList<long[]> debtors   = new LinkedList<>();

        Map<Long, String> nicknameMap = balances.stream()
                .collect(Collectors.toMap(
                        ExpenseDto.MemberShareSummary::getMemberId,
                        ExpenseDto.MemberShareSummary::getNickname,
                        (a, b) -> a  // 중복 키 발생 시 첫 번째 값 유지
                ));

        for (ExpenseDto.MemberShareSummary b : balances) {
            BigDecimal bal = b.getBalance();
            if (bal == null) continue;
            int cmp = bal.compareTo(BigDecimal.ZERO);
            if (cmp > 0) {
                creditors.add(new long[]{b.getMemberId(),
                        bal.setScale(0, RoundingMode.HALF_UP).longValue()});
            } else if (cmp < 0) {
                debtors.add(new long[]{b.getMemberId(),
                        bal.abs().setScale(0, RoundingMode.HALF_UP).longValue()});
            }
        }

        while (!creditors.isEmpty() && !debtors.isEmpty()) {
            long[] creditor = creditors.peek();
            long[] debtor   = debtors.peek();
            long   settle   = Math.min(creditor[1], debtor[1]);

            result.add(SettlementDto.SettlementDetail.builder()
                    .fromMemberId(debtor[0])
                    .fromMemberNickname(nicknameMap.get(debtor[0]))
                    .toMemberId(creditor[0])
                    .toMemberNickname(nicknameMap.get(creditor[0]))
                    .amount(BigDecimal.valueOf(settle))
                    .build());

            creditor[1] -= settle;
            debtor[1]   -= settle;

            if (creditor[1] == 0) creditors.poll();
            if (debtor[1]   == 0) debtors.poll();
        }

        return result;
    }
}
