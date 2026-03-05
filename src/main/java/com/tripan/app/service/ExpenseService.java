package com.tripan.app.service;

import com.tripan.app.domain.dto.ExpenseDto;
public interface ExpenseService {

    /**
     * 지출 등록 및 분담금 생성
     * @param tripId 여행 방 ID
     * @param payerId 결제한 사람의 멤버 ID
     * @param dto 지출 내역 및 분담할 멤버 리스트가 담긴 DTO
     * @return 생성된 지출 내역 ID (expenseId)
     */
	public Long addExpense(Long tripId, Long payerId, ExpenseDto dto);

    /**
     * 개별 건별 정산 처리 
     * 특정 지출 건에 대해 돈을 보냈을 때 본인의 분담 내역을 완료(1)로 변경
     * @param participantId 완료 처리할 분담 내역(ExpenseParticipant)의 ID
     */
	public void settleIndividualExpense(Long participantId);

    /**
     * 지출 내역 삭제 
     * 분담 내역(ExpenseParticipant)을 먼저 일괄 삭제한 후, 본 데이터(Expense)를 삭제
     * @param expenseId 삭제할 지출 내역 ID
     */
	public void deleteExpense(Long expenseId);

    /**
     * 여행 종료 후 최종 정산
     * @param tripId 정산을 진행할 여행 방 ID
     */
	public void calculateFinalSettlement(Long tripId);



}