package com.tripan.app.controller;

import java.io.File;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.springframework.http.ResponseEntity;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestAttribute;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.tripan.app.domain.dto.ExpenseDto;
import com.tripan.app.domain.dto.SettlementDto;
import com.tripan.app.mapper.ExpenseMapper;
import com.tripan.app.service.ExpenseService;
import com.tripan.app.service.NotificationService; // ★ 추가

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class ExpenseController {

    private final ExpenseService expenseService;
    private final ExpenseMapper expenseMapper;
    private final SimpMessagingTemplate messagingTemplate;
    private final NotificationService notificationService; // ★ 추가 (생성자 주입 자동 처리)

    // ════════════════════════════════════════════════════════
    //  지출 API
    // ════════════════════════════════════════════════════════

    /**
     * 지출 등록
     * POST /api/trips/{tripId}/expenses
     *
     * ★ Bug Fix: 지출 추가 시 알림 발송 + WebSocket 브로드캐스트 추가
     */
    @PostMapping("/trips/{tripId}/expenses")
    public ResponseEntity<ExpenseDto.DetailResponse> createExpense(
            @PathVariable("tripId") Long tripId,
            @RequestBody ExpenseDto.CreateRequest req,
            HttpSession session) { // ★ session 추가 (senderId 추출용)

        req.setTripId(tripId);
        ExpenseDto.DetailResponse result = expenseService.createExpense(req);

        // ★ 알림 발송 (결제자를 제외한 모든 멤버에게)
        try {
            Long senderId    = req.getPayerId();
            String payerNick = result.getPayerNickname() != null ? result.getPayerNickname() : "누군가";
            String desc      = result.getDescription()  != null ? result.getDescription()  : "";
            long   amount    = result.getAmount() != null ? result.getAmount().longValue() : 0L;

            String message = payerNick + "님이 새 지출을 추가했어요: "
                    + desc + " ₩" + String.format("%,d", amount);

            // DB 알림 저장 (결제자 제외 전체)
            notificationService.notifyAll(tripId, senderId, message, "EXPENSE");

            // WebSocket: 알림 벨 갱신
            Map<String, Object> notifMsg = new HashMap<>();
            notifMsg.put("type", "NEW_NOTIFICATION");
            messagingTemplate.convertAndSend("/sub/trip/" + tripId, notifMsg);

            // WebSocket: 지출 목록 실시간 갱신 (EXPENSE_ADDED는 workspace_ws.js에서 이미 처리됨)
            Map<String, Object> expMsg = new HashMap<>();
            expMsg.put("type", "EXPENSE_ADDED");
            expMsg.put("senderNickname", payerNick);
            messagingTemplate.convertAndSend("/sub/trip/" + tripId, expMsg);

        } catch (Exception e) {
            // 알림 실패가 지출 등록을 막으면 안 됨
            e.printStackTrace();
        }

        return ResponseEntity.ok(result);
    }
    
    /**
     * 단건 정산 요청 생성
     * POST /api/trips/{tripId}/settlements/request
     * body: { fromMemberId, amount }
     */
    @PostMapping("/trips/{tripId}/settlements/request")
    public ResponseEntity<Map<String, Object>> requestSingleSettlement(
            @PathVariable("tripId") Long tripId,
            @RequestBody Map<String, Object> body,
            HttpSession session) {

        Map<String, Object> result = new HashMap<>();
        Long myId = getLoginMemberId(session);
        if (myId == null) {
            result.put("success", false);
            result.put("message", "로그인이 필요합니다.");
            return ResponseEntity.status(401).body(result);
        }

        try {
            Long fromMemberId = Long.valueOf(String.valueOf(body.get("fromMemberId")));
            java.math.BigDecimal amount = new java.math.BigDecimal(String.valueOf(body.get("amount")));

            int existing = expenseMapper.countActiveSettlement(tripId, myId, fromMemberId);

            // ★ 단건 정산에도 batch_id 부여 → settlement_expense_link 연결 가능
            Long batchId = expenseMapper.selectNextBatchId();

            SettlementDto.SingleRequest req = SettlementDto.SingleRequest.builder()
                    .tripId(tripId)
                    .toMemberId(myId)
                    .fromMemberId(fromMemberId)
                    .amount(amount)
                    .batchId(batchId)
                    .build();

            if (existing > 0) {
                // 기존 정산 업데이트: 금액만 갱신 (batch_id는 이미 있으므로 유지)
                expenseMapper.updateSingleSettlementAmount(req);
            } else {
                // 신규 INSERT (batch_id 포함)
                expenseMapper.insertSingleSettlement(req);

                // ★ 이 pair(결제자=myId, 분담자=fromMemberId)의 미정산 expense 연결
                java.util.List<Long> pairExpIds =
                    expenseMapper.selectPairExpenseIds(tripId, myId, fromMemberId);
                if (!pairExpIds.isEmpty()) {
                    java.util.List<java.util.Map<String, Object>> linkRows = new java.util.ArrayList<>();
                    for (Long eid : pairExpIds) {
                        java.util.Map<String, Object> row = new java.util.HashMap<>();
                        row.put("batchId",   batchId);
                        row.put("expenseId", eid);
                        row.put("tripId",    tripId);
                        linkRows.add(row);
                    }
                    expenseMapper.insertSettlementExpenseLinks(linkRows);
                }
            }

            // 알림 발송
            String message = "정산 요청이 도착했어요! ₩"
                    + String.format("%,d", amount.longValue()) + " 을 확인해주세요.";
            expenseMapper.insertTripNotification(tripId, fromMemberId, myId, message, "EXPENSE");
            
            Map<String, Object> wsMsg = new HashMap<>();
            wsMsg.put("type", "NEW_NOTIFICATION");
            messagingTemplate.convertAndSend("/sub/trip/" + tripId, wsMsg);
            
            result.put("success", true);
            result.put("message", "정산을 요청했어요!");
        } catch (Exception e) {
        	e.printStackTrace();
            result.put("success", false);
            result.put("message", e.getMessage());
        }
        return ResponseEntity.ok(result);
    }

    /**
     * 지출 목록 조회 (페이징)
     * GET /api/trips/{tripId}/expenses
     */
    @GetMapping("/trips/{tripId}/expenses")
    public ResponseEntity<List<ExpenseDto.SummaryResponse>> getExpenseList(
            @PathVariable("tripId") Long tripId,
            @RequestParam(value = "page", defaultValue = "1")  int page,
            @RequestParam(value = "size", defaultValue = "20") int size) {

        return ResponseEntity.ok(expenseService.getExpenseList(tripId, page, size));
    }

    /**
     * 지출 전체 조회 (참여자 포함) — 정산 계산용
     * GET /api/trips/{tripId}/expenses/with-participants
     */
    @GetMapping("/trips/{tripId}/expenses/with-participants")
    public ResponseEntity<List<ExpenseDto.DetailResponse>> getExpensesWithParticipants(
            @PathVariable("tripId") Long tripId) {

        List<ExpenseDto.SummaryResponse> summaries = expenseService.getExpenseList(tripId, 1, 500);
        List<ExpenseDto.DetailResponse> result = new java.util.ArrayList<>();

        for (ExpenseDto.SummaryResponse s : summaries) {
            ExpenseDto.DetailResponse detail = expenseMapper.selectExpenseDetailById(s.getExpenseId());
            if (detail != null) {
                detail.setParticipants(expenseMapper.selectParticipantsByExpenseId(s.getExpenseId()));
                result.add(detail);
            }
        }
        return ResponseEntity.ok(result);
    }

    /**
     * 지출 통계 (카테고리별, 멤버별 결제/부담)
     * GET /api/trips/{tripId}/expenses/summary
     */
    @GetMapping("/trips/{tripId}/expenses/summary")
    public ResponseEntity<ExpenseDto.TripSummaryResponse> getExpenseSummary(
            @PathVariable("tripId") Long tripId) {

        return ResponseEntity.ok(expenseService.getTripExpenseSummary(tripId));
    }

    /**
     * 지출 상세 조회
     * GET /api/expenses/{expenseId}
     */
    @GetMapping("/expenses/{expenseId}")
    public ResponseEntity<ExpenseDto.DetailResponse> getExpenseDetail(
            @PathVariable("expenseId") Long expenseId) {

        return ResponseEntity.ok(expenseService.getExpenseDetail(expenseId));
    }

    /**
     * 지출 수정 (분담자 전체 교체)
     * PUT /api/expenses/{expenseId}
     */
    @PutMapping("/expenses/{expenseId}")
    public ResponseEntity<ExpenseDto.DetailResponse> updateExpense(
            @PathVariable("expenseId") Long expenseId,
            @RequestBody ExpenseDto.UpdateRequest req) {

        return ResponseEntity.ok(expenseService.updateExpense(expenseId, req));
    }

    /**
     * 지출 삭제
     * DELETE /api/expenses/{expenseId}
     */
    @DeleteMapping("/expenses/{expenseId}")
    public ResponseEntity<Void> deleteExpense(
            @PathVariable("expenseId") Long expenseId) {

        expenseService.deleteExpense(expenseId);
        return ResponseEntity.noContent().build();
    }

    // ════════════════════════════════════════════════════════
    //  정산 API
    // ════════════════════════════════════════════════════════

    /**
     * 정산 미리보기 (DB 저장 없음)
     * GET /api/trips/{tripId}/settlements/preview
     */
    @GetMapping("/trips/{tripId}/settlements/preview")
    public ResponseEntity<SettlementDto.PreviewResponse> previewSettlement(
            @PathVariable("tripId") Long tripId) {

        return ResponseEntity.ok(expenseService.previewSettlement(tripId));
    }

    /**
     * 정산 일괄 생성 (DB 저장)
     * POST /api/trips/{tripId}/settlements
     */
    @PostMapping("/trips/{tripId}/settlements")
    public ResponseEntity<SettlementDto.TripSettlementResponse> createSettlements(
            @PathVariable("tripId") Long tripId,
            @RequestBody SettlementDto.CreateBatchRequest req,
            @RequestAttribute(name = "loginMemberId", required = false) Long loginMemberId,
            @RequestParam(value = "memberId", required = false) Long memberIdParam) {

        req.setTripId(tripId);
        Long memberId = loginMemberId != null ? loginMemberId
                      : memberIdParam   != null ? memberIdParam
                      : 0L;
        return ResponseEntity.ok(expenseService.createSettlements(req, memberId));
    }

    /**
     * 여행 전체 정산 현황 조회
     * GET /api/trips/{tripId}/settlements
     */
    @GetMapping("/trips/{tripId}/settlements")
    public ResponseEntity<SettlementDto.TripSettlementResponse> getSettlements(
            @PathVariable("tripId") Long tripId,
            @RequestAttribute(name = "loginMemberId", required = false) Long loginMemberId,
            @RequestParam(value = "memberId", required = false) Long memberIdParam) {

        Long memberId = loginMemberId != null ? loginMemberId
                      : memberIdParam   != null ? memberIdParam
                      : 0L;
        return ResponseEntity.ok(expenseService.getTripSettlements(tripId, memberId));
    }

    /**
     * 정산 완료 처리 (송금 체크)
     */
    @PostMapping("/settlements/complete")
    public ResponseEntity<Void> completeSettlements(
            @RequestBody SettlementDto.CompleteRequest req) {

        expenseService.completeSettlements(req);
        return ResponseEntity.ok().build();
    }


    /**
     * 정산 완료 batch 상세 조회
     * GET /api/trips/{tripId}/settlements/batch/{batchId}/detail
     */
    @GetMapping("/trips/{tripId}/settlements/batch/{batchId}/detail")
    public ResponseEntity<SettlementDto.BatchDetailResponse> getBatchDetail(
            @PathVariable("tripId")  Long tripId,
            @PathVariable("batchId") Long batchId) {
        return ResponseEntity.ok(expenseService.getBatchDetail(tripId, batchId));
    }

    /**
     * 정산 단건 삭제
     * DELETE /api/settlements/{settlementId}
     */
    @DeleteMapping("/settlements/{settlementId}")
    public ResponseEntity<Void> deleteSettlement(
            @PathVariable("settlementId") Long settlementId) {

        expenseService.deleteSettlement(settlementId);
        return ResponseEntity.noContent().build();
    }
    
    /**
     * 영수증 이미지 업로드
     * POST /api/upload/receipt
     */
    @PostMapping("/upload/receipt")
    public ResponseEntity<Map<String, Object>> uploadReceipt(
            @RequestParam("file") MultipartFile file,
            HttpSession session) {

        Map<String, Object> result = new HashMap<>();
        try {
            String uploadDir = System.getProperty("user.home") + "/tripan-uploads/receipts/";
            new File(uploadDir).mkdirs();

            String originalFilename = file.getOriginalFilename() != null
                    ? file.getOriginalFilename() : "receipt.jpg";
            String ext = originalFilename.substring(originalFilename.lastIndexOf('.'));
            String fileName = UUID.randomUUID().toString() + ext;

            file.transferTo(new File(uploadDir + fileName));

            String url = "/receipts/" + fileName;
            result.put("success", true);
            result.put("url", url);
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", e.getMessage());
        }
        return ResponseEntity.ok(result);
    }

    /**
     * 나에게 온 정산 요청 건수 (홈탭 대기 칩용)
     * GET /api/trips/{tripId}/settlements/incoming-count
     */
    @GetMapping("/trips/{tripId}/settlements/incoming-count")
    public ResponseEntity<Map<String, Object>> getIncomingSettlementCount(
            @PathVariable("tripId") Long tripId,
            HttpSession session) {

        Map<String, Object> result = new HashMap<>();
        Long myId = getLoginMemberId(session);
        if (myId == null) {
            result.put("count", 0);
            return ResponseEntity.ok(result);
        }
        int count = expenseMapper.countIncomingSettlementRequests(tripId, myId);
        result.put("count", count);
        result.put("memberId", myId);
        return ResponseEntity.ok(result);
    }

    /**
     * 내가 결제한 카테고리별 지출 합계
     * GET /api/trips/{tripId}/expenses/my-categories
     */
    @GetMapping("/trips/{tripId}/expenses/my-categories")
    public ResponseEntity<List<ExpenseDto.CategorySummary>> getMyCategorySummary(
            @PathVariable("tripId") Long tripId,
            HttpSession session) {

        Long myId = getLoginMemberId(session);
        if (myId == null) return ResponseEntity.ok(List.of());
        return ResponseEntity.ok(expenseMapper.selectMyCategorySummaryByTripId(tripId, myId));
    }

    // 헬퍼 — session에서 memberId 추출
    private Long getLoginMemberId(HttpSession session) {
        try {
            Object user = session.getAttribute("loginUser");
            if (user == null) return null;
            return (Long) user.getClass().getMethod("getMemberId").invoke(user);
        } catch (Exception e) { return null; }
    }
}