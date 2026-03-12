package com.tripan.app.service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Deque;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.tripan.app.domain.dto.ExpenseDto;
import com.tripan.app.trip.domain.entity.Expense;
import com.tripan.app.trip.domain.entity.ExpenseCategory;
import com.tripan.app.trip.domain.entity.ExpenseParticipant;
import com.tripan.app.trip.domain.entity.Settlement;
import com.tripan.app.trip.repository.ExpenseParticipantRepository;
import com.tripan.app.trip.repository.ExpenseRepository;
import com.tripan.app.trip.repository.SettlementRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ExpenseServiceImpl implements ExpenseService {

    private final ExpenseRepository expenseRepository;
    private final ExpenseParticipantRepository participantRepository;
    private final SettlementRepository settlementRepository;
    // Member 닉네임 조회용 (없으면 주석 처리 가능)
    // private final MemberRepository memberRepository;

    // ── 지출 목록 조회 ──────────────────────────────────────

    @Override
    @Transactional(readOnly = true)
    public java.util.List<java.util.Map<String, Object>> getExpenseList(Long tripId) {
        List<Expense> expenses = expenseRepository.findByTripIdOrderByExpenseDateDesc(tripId);
        return expenses.stream().map(e -> {
            java.util.Map<String, Object> map = new java.util.LinkedHashMap<>();
            map.put("expenseId",    e.getExpenseId());
            map.put("category",     e.getCategory() != null ? e.getCategory().name() : "ETC");
            map.put("description",  e.getDescription());
            map.put("amount",       e.getAmount());
            map.put("expenseDate",  e.getExpenseDate() != null ? e.getExpenseDate().toString() : null);
            map.put("isPrivate",    e.getIsPrivate());
            map.put("payerNickname", null); // TODO: member 조회로 교체
            return map;
        }).collect(java.util.stream.Collectors.toList());
    }

    @Override
    @Transactional
    public Long addExpense(ExpenseDto.ExpenseCreate dto) {
        Expense expense = new Expense();
        expense.setTripId(dto.getTripId());
        expense.setPayerId(dto.getPayerId());
        expense.setCategory(ExpenseCategory.valueOf(dto.getCategory().toUpperCase()));
        expense.setAmount(dto.getAmount().intValue());  
        expense.setDescription(dto.getDescription());
        expense.setExpenseDate(dto.getExpenseDate());
        expense.setPaymentType(dto.getPaymentType());
        expense.setMemo(dto.getMemo());
        expense.setIsPrivate(dto.getIsPrivate());
        expense.setCreatedAt(LocalDateTime.now());
        
        Expense saved = expenseRepository.save(expense);
        Long expenseId = saved.getExpenseId();

        // N빵 계산 로직 - participantMemberIds가 없으면 결제자 단독으로 처리
        List<Long> memberIds = dto.getParticipantMemberIds();
        if (memberIds == null || memberIds.isEmpty()) {
            // 결제자만 있을 경우 단독 저장 (정산 불필요)
            if (dto.getPayerId() != null) {
                ExpenseParticipant ep = new ExpenseParticipant();
                ep.setExpenseId(expenseId);
                ep.setMemberId(dto.getPayerId());
                ep.setShareAmount(expense.getAmount());
                ep.setIsSettled(0);
                participantRepository.save(ep);
            }
            return expenseId;
        }
        int count = memberIds.size();
        int total = expense.getAmount();
        int base = total / count;          
        int remain = total - (base * count); 

        for (Long mId : memberIds) {
            ExpenseParticipant ep = new ExpenseParticipant();
            ep.setExpenseId(expenseId);
            ep.setMemberId(mId);
            
            int share = base;
            // 나머지는 결제자에게 할당하여 무결성 유지 
            if (remain > 0 && mId.equals(dto.getPayerId())) {
                share += remain;
                remain = 0;
            }
            ep.setShareAmount(share);
            ep.setIsSettled(0); // 0 = 미정산 / 1 = 정산
            participantRepository.save(ep);
        }
        return expenseId;
    }

    @Override
    @Transactional
    public List<ExpenseDto.SettlementResult> calculateSettlement(Long tripId) {
        List<Expense> expenses = expenseRepository.findByTripId(tripId);
        Map<Long, Integer> balance = new HashMap<>();

        // 멤버별 잔액 계산 
        for (Expense expense : expenses) {
            balance.merge(expense.getPayerId(), expense.getAmount(), Integer::sum);
            List<ExpenseParticipant> participants = participantRepository.findByExpenseId(expense.getExpenseId());
            for (ExpenseParticipant p : participants) {
                balance.merge(p.getMemberId(), -p.getShareAmount(), Integer::sum);
            }
        }

        Deque<long[]> givers = new ArrayDeque<>(); 
        Deque<long[]> takers = new ArrayDeque<>(); 

        balance.forEach((id, val) -> {
            if (val > 0) givers.addLast(new long[]{id, val});
            else if (val < 0) takers.addLast(new long[]{id, -val});
        });

        List<ExpenseDto.SettlementResult> results = new ArrayList<>();

        while (!givers.isEmpty() && !takers.isEmpty()) {
            long[] giver = givers.peekFirst();
            long[] taker = takers.peekFirst();
            long transfer = Math.min(giver[1], taker[1]);

            ExpenseDto.SettlementResult result = new ExpenseDto.SettlementResult();
            result.setFromMemberId(taker[0]);
            result.setToMemberId(giver[0]);
            result.setAmount(BigDecimal.valueOf(transfer));
            result.setFromNickname("멤버" + taker[0]);
            result.setToNickname("멤버" + giver[0]);
            results.add(result);

            // DB에 정산 영수증 생성
            Settlement settlement = new Settlement();
            settlement.setTripId(tripId);
            settlement.setAmount(BigDecimal.valueOf(transfer));
            settlement.setStatus("PENDING");
            settlement.setCreatedAt(LocalDateTime.now());
            settlementRepository.save(settlement);

            giver[1] -= transfer;
            taker[1] -= transfer;
            if (giver[1] == 0) givers.pollFirst();
            if (taker[1] == 0) takers.pollFirst();
        }
        return results;
    }

    @Override
    @Transactional
    public void settleIndividual(Long participantId) {
    	participantRepository.updateIsSettled(participantId, 1);
    }

    @Override
    @Transactional
    public void completeSettlement(Long settlementId) {
        settlementRepository.updateStatusAndSettledAt(settlementId, "COMPLETED", LocalDateTime.now());
    }

    @Override
    @Transactional
    public void deleteExpense(Long expenseId) {
        // 정산 완료(1) 상태가 있는지 체크 
        if (participantRepository.existsByExpenseIdAndIsSettled(expenseId, 1)) {
            throw new IllegalStateException("정산이 완료된 지출은 삭제할 수 없습니다");
        }
        
        participantRepository.deleteByExpenseId(expenseId);
        expenseRepository.deleteById(expenseId); 
    }
}