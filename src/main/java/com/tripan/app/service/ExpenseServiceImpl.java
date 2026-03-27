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
import com.tripan.app.trip.repository.ExpenseRepository;
import com.tripan.app.trip.repository.SettlementRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ExpenseServiceImpl implements ExpenseService {

    private final ExpenseRepository expenseRepository;
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
        // ★ SETTLED 지출 제외한 balance 계산
        List<ExpenseDto.MemberShareSummary> shares = expenseMapper.calculateBalancesForUnlinkedExpenses(tripId);

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
        // 미완료 expense만 대상으로 미리보기 계산
        List<ExpenseDto.MemberShareSummary> balances =
                expenseMapper.calculateBalancesForUnlinkedExpenses(tripId);
        List<SettlementDto.SettlementDetail> details = calculateOptimalSettlements(balances);

        return SettlementDto.PreviewResponse.builder()
                .tripId(tripId)
                .details(details)
                .build();
    }

    /**
     * 정산 일괄 생성
     *
     * ★ 핵심 변경: settlement_expense_link 기반 재정산
     * - COMPLETED batch에 연결된 expense는 재정산 대상에서 제외
     * - 새 batch 생성 후 계산 대상 expense를 settlement_expense_link에 저장
     *
     * [흐름]
     * ① PENDING/REQUESTED 정산 삭제 (COMPLETED 보존)
     * ② COMPLETED batch 미연결 expense만 balance 계산
     * ③ 최적 정산 경로 계산
     * ④ settlement INSERT
     * ⑤ settlement_expense_link INSERT (② 목록 전체 연결)
     */
    @Override
    @Transactional
    public SettlementDto.TripSettlementResponse createSettlements(
            SettlementDto.CreateBatchRequest req, Long requestMemberId) {

        Long tripId = req.getTripId();

        // ① COMPLETED 제외하고 PENDING/REQUESTED 만 삭제
        settlementRepository.deleteNonCompletedByTripId(tripId);

        // ② COMPLETED batch에 포함되지 않은 expense만 대상으로 balance 계산
        List<ExpenseDto.MemberShareSummary> balances =
                expenseMapper.calculateBalancesForUnlinkedExpenses(tripId);

        // ③ 최적 정산 경로 계산
        List<SettlementDto.SettlementDetail> details = calculateOptimalSettlements(balances);

        if (details.isEmpty()) {
            return getTripSettlements(tripId, requestMemberId);
        }

        // ④ batch_id 결정 후 settlement 저장
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

        // ⑤ 이번 정산에 포함된 expense 목록 → settlement_expense_link INSERT
        List<Long> settledExpenseIds = expenseMapper.selectSettledExpenseIdsByTripId(tripId);
        // ★ 혼자 쓴 지출 제외: participants 중 서로 다른 member_id가 2명 이상인 expense만 포함
        //   XML 쿼리 없이 Java 코드로 직접 판별 (participants fetch join 활용)
        List<Expense> allExpenses = expenseRepository.findAllWithParticipantsByTripId(tripId);
        List<Long> allExpenseIds = allExpenses.stream()
                .filter(e -> {
                    // 이미 정산 완료된 지출 제외
                    if (settledExpenseIds.contains(e.getExpenseId())) return false;
                    // 혼자 쓴 지출 제외: distinct member_id 2개 이상이어야 정산 대상
                    long distinctMembers = e.getParticipants().stream()
                            .filter(ep -> ep.getMemberId() != null)
                            .map(ep -> ep.getMemberId())
                            .distinct()
                            .count();
                    return distinctMembers >= 2;
                })
                .map(Expense::getExpenseId)
                .collect(Collectors.toList());

        if (!allExpenseIds.isEmpty()) {
            List<Map<String, Object>> linkRows = new ArrayList<>();
            for (Long eid : allExpenseIds) {
                Map<String, Object> row = new HashMap<>();
                row.put("batchId",   batchId);
                row.put("expenseId", eid);
                row.put("tripId",    tripId);
                linkRows.add(row);
            }
            expenseMapper.insertSettlementExpenseLinks(linkRows);
        }

        return getTripSettlements(tripId, requestMemberId);
    }

    @Override
    @Transactional
    public void completeSettlements(SettlementDto.CompleteRequest req) {
        /*
         * ★ 최종 수정: settlement row의 status/settledAt만 COMPLETED로 변경
         *
         * settlement_expense_link는 건드리지 않음.
         *
         * [이유]
         * settlement_expense_link는 expense 단위로 연결됨.
         * 한 expense에 참여자가 여러 명이면,
         * 1명 완료 시 그 expense가 SETTLED → 다른 참여자 정산도 화면에서 사라지는 버그.
         *
         * [해결]
         * 프론트 p2pMap이 settleStatus(expense 단위) 대신
         * COMPLETED settlement의 (fromMid, toMid) 페어를 직접 비교해서 제외.
         * → 다른 참여자에게 영향 없이 정확하게 동작.
         * → settlement row만 COMPLETED로 바꾸면 충분.
         *
         * JPA dirty checking으로 자동 UPDATE됨.
         */
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
    //  정산 batch 상세 조회 (완료 상세보기용)
    // ════════════════════════════════════════════════════════

    @Override
    public SettlementDto.BatchDetailResponse getBatchDetail(Long tripId, Long batchId) {
        List<SettlementDto.Response> transfers = expenseMapper.selectBatchTransfers(tripId, batchId);
        List<ExpenseDto.DetailResponse> expenses = expenseMapper.selectExpensesByBatchId(tripId, batchId);
        for (ExpenseDto.DetailResponse exp : expenses) {
            exp.setParticipants(expenseMapper.selectParticipantsByExpenseId(exp.getExpenseId()));
        }
        List<ExpenseDto.MemberShareSummary> memberSummary =
                expenseMapper.selectBatchMemberSummary(tripId, batchId);

        BigDecimal totalAmount = transfers.stream()
                .map(SettlementDto.Response::getAmount)
                .filter(a -> a != null)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        java.time.LocalDateTime settledAt = transfers.stream()
                .map(SettlementDto.Response::getSettledAt)
                .filter(d -> d != null)
                .findFirst().orElse(null);

        return SettlementDto.BatchDetailResponse.builder()
                .batchId(batchId)
                .tripId(tripId)
                .status("COMPLETED")
                .settledAt(settledAt)
                .totalAmount(totalAmount)
                .transfers(transfers)
                .expenses(expenses)
                .memberSummary(memberSummary)
                .build();
    }

    // ════════════════════════════════════════════════════════
    //  Private 헬퍼
    // ════════════════════════════════════════════════════════

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