package com.tripan.app.service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.ArrayList;
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
    //  지출 CRUD  (Repository 사용)
    // ════════════════════════════════════════════════════════

    /**
     * 지출 등록
     * expense + expense_participant 동시 저장 (CascadeType.ALL)
     */
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
                            .memberId(p.getMemberId())                    /* 외부 인원은 null */
                            .nickname(p.getNickname())                    /* 외부 인원 이름 */
                            .shareAmount(p.getShareAmount())
                            .build()
            );
        }

        Expense saved = expenseRepository.save(expense);
        // 저장 후 닉네임 포함 상세 조회는 Mapper(XML) 사용
        return expenseMapper.selectExpenseDetailById(saved.getExpenseId());
    }

    /**
     * 지출 수정 (분담자 전체 교체)
     */
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

        // orphanRemoval = true → clear() 후 add() 하면 기존 participant 자동 DELETE 후 INSERT
        expense.getParticipants().clear();
        for (ExpenseDto.ParticipantRequest p : req.getParticipants()) {
            expense.getParticipants().add(
                    ExpenseParticipant.builder()
                            .expense(expense)
                            .memberId(p.getMemberId())                    /* 외부 인원은 null */
                            .nickname(p.getNickname())                    /* 외부 인원 이름 */
                            .shareAmount(p.getShareAmount())
                            .build()
            );
        }

        // dirty checking으로 자동 저장, 응답은 Mapper로 조회
        return expenseMapper.selectExpenseDetailById(expenseId);
    }

    /**
     * 지출 삭제 (cascade → expense_participant 자동 삭제)
     */
    @Override
    @Transactional
    public void deleteExpense(Long expenseId) {
        Expense expense = expenseRepository.findById(expenseId)
                .orElseThrow(() -> new IllegalArgumentException("지출 정보를 찾을 수 없습니다. id=" + expenseId));
        expenseRepository.delete(expense);
    }

    // ════════════════════════════════════════════════════════
    //  지출 조회  (Mapper XML 사용)
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

    /**
     * 정산 미리보기 (DB 저장 없음)
     * expense_participant 기반으로 최적 정산 경로 계산
     */
    @Override
    public SettlementDto.PreviewResponse previewSettlement(Long tripId) {
        List<ExpenseDto.MemberShareSummary> balances = expenseMapper.calculateBalancesByTripId(tripId);
        List<SettlementDto.SettlementDetail> details = calculateOptimalSettlements(balances);

        return SettlementDto.PreviewResponse.builder()
                .tripId(tripId)
                .details(details)
                .build();
    }

    /**
     * 정산 일괄 생성 → Repository로 저장
     * 기존 PENDING 정산이 있으면 삭제 후 재생성
     */
    @Override
    @Transactional
    public SettlementDto.TripSettlementResponse createSettlements(
            SettlementDto.CreateBatchRequest req, Long requestMemberId) {

        Long tripId = req.getTripId();

        // 기존 정산 초기화 (재정산)
        settlementRepository.deleteByTripId(tripId);

        // balance 계산 → 최적 정산 목록 생성
        List<ExpenseDto.MemberShareSummary> balances = expenseMapper.calculateBalancesByTripId(tripId);
        List<SettlementDto.SettlementDetail> details = calculateOptimalSettlements(balances);

        // batch_id 결정
        Long batchId = req.getBatchId() != null
                ? req.getBatchId()
                : settlementRepository.generateNextBatchId();

        // Settlement 엔티티 생성 → Repository로 저장
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

    /** 정산 완료 처리 → Repository로 상태 변경 */
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

    /** 정산 단건 삭제 */
    @Override
    @Transactional
    public void deleteSettlement(Long settlementId) {
        settlementRepository.findById(settlementId).ifPresent(settlementRepository::delete);
    }

    /** 여행 전체 정산 현황 조회 → Mapper(XML)로 조회 */
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
     * 분담 금액 합계 검증
     * participants의 shareAmount 합 == expense.amount 이어야 함
     */
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
     * 최적 정산 계산 알고리즘 (최소 이체 횟수)
     * balance > 0 : 받을 사람 (채권자)
     * balance < 0 : 보낼 사람 (채무자)
     * 가장 큰 채권자 ↔ 가장 큰 채무자부터 greedy 매칭
     */
    private List<SettlementDto.SettlementDetail> calculateOptimalSettlements(
            List<ExpenseDto.MemberShareSummary> balances) {

        List<SettlementDto.SettlementDetail> result = new ArrayList<>();

        LinkedList<long[]> creditors = new LinkedList<>(); // [memberId, balance(+)]
        LinkedList<long[]> debtors   = new LinkedList<>(); // [memberId, |balance|(-)]

        Map<Long, String> nicknameMap = balances.stream()
                .collect(Collectors.toMap(
                        ExpenseDto.MemberShareSummary::getMemberId,
                        ExpenseDto.MemberShareSummary::getNickname
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
