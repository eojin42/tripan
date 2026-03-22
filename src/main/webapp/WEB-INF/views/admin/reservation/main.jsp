<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>TripanSuper — 전체 예약 관리</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/admin.css">
  <style>
    .reservation-number { font-weight: 800; color: var(--text); letter-spacing: 0.2px; }
    .reservation-sub { font-size: 12px; color: var(--muted); margin-top: 4px; }
    .cell-stack { display: flex; flex-direction: column; gap: 4px; }
    .table-topbar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 18px; }
    .table-topbar h2 { font-size: 15px; font-weight: 800; }
    .empty-row { text-align: center; color: var(--muted); padding: 48px 16px !important; }
    .receipt-info-list { display: flex; flex-direction: column; gap: 12px; }
    .receipt-info-row { display: flex; justify-content: space-between; gap: 12px; font-size: 14px; }
    .receipt-info-row strong { min-width: 120px; color: var(--muted); }
    .status-action-wrap { display: flex; gap: 8px; flex-wrap: wrap; }
    .coupon-item { display: flex; flex-direction: column; gap: 2px; padding: 6px 0; border-bottom: 1px dashed var(--border); }
    .coupon-item:last-child { border-bottom: none; }
    .coupon-name { font-weight: 600; font-size: 13px; }
    .coupon-amount { font-size: 13px; color: var(--danger); }
    .coupon-share { font-size: 11px; color: var(--muted); }
    .coupon-section-label { font-size: 13px; color: var(--muted); margin-bottom: 4px; }
  </style>
</head>
<body>
<div class="admin-layout">
  <jsp:include page="../layout/sidebar.jsp">
    <jsp:param name="activePage" value="allReservations"/>
  </jsp:include>

  <div class="main-wrapper">
    <jsp:include page="../layout/header.jsp" />

    <main class="main-content">

      <div class="page-header fade-up">
        <div>
          <h1>전체 예약 관리</h1>
          <p>전체 예약 현황, 결제, 취소, 환불을 통합 관리합니다.</p>
        </div>
      </div>

      <!-- KPI -->
      <div class="kpi-grid">
        <div class="card kpi-card fade-up fade-up-1">
          <div class="kpi-label">전체 예약</div>
          <div class="kpi-value" id="kpiTotalCount">0</div>
          <div class="kpi-sub">조회 조건 기준 전체 예약 건수</div>
        </div>
        <div class="card kpi-card fade-up fade-up-2">
          <div class="kpi-label">예약 완료</div>
          <div class="kpi-value" id="kpiReserved" style="color: var(--primary);">0</div>
          <div class="kpi-sub">체크아웃 전 예약</div>
        </div>
        <div class="card kpi-card fade-up fade-up-3">
          <div class="kpi-label">이용 완료</div>
          <div class="kpi-value" id="kpiUsed" style="color: var(--success);">0</div>
          <div class="kpi-sub">체크아웃 완료 건</div>
        </div>
        <div class="card kpi-card fade-up fade-up-4">
          <div class="kpi-label">취소 / 환불</div>
          <div class="kpi-value" id="kpiCancelled" style="color: var(--danger);">0</div>
          <div class="kpi-sub">취소 및 환불 진행/완료 건</div>
        </div>
      </div>

      <!-- FILTER -->
      <div class="card filter-card fade-up">
        <div class="filter-row">
          <div class="filter-label">기간</div>
          <div class="date-range">
            <input type="date" id="startDate" class="date-input">
            <span class="date-sep">~</span>
            <input type="date" id="endDate" class="date-input">
          </div>
          <div class="filter-label">예약상태</div>
          <select id="status" class="filter-select" style="width:160px;">
            <option value="">전체</option>
            <option value="SUCCESS">예약완료</option>
            <option value="CANCELED">취소</option>
          </select>
          <div class="filter-label">결제상태</div>
          <select id="paymentStatus" class="filter-select" style="width:160px;">
            <option value="">전체</option>
            <option value="결제완료">결제완료</option>
            <option value="예약중">예약중</option>
            <option value="예약확정">예약확정</option>
            <option value="취소처리중">취소처리중</option>
            <option value="취소완료">취소완료</option>
          </select>
        </div>
        <div class="filter-row">
          <div class="filter-label">검색</div>
          <select id="keywordType" class="filter-select" style="width:150px;">
            <option value="reservationId">예약번호</option>
            <option value="memberName">예약자명</option>
            <option value="placeName">숙소명</option>
          </select>
          <input type="text" id="keyword" class="keyword-input" placeholder="예약번호 / 예약자명 / 숙소명 입력">
          <div class="filter-actions">
            <button class="btn btn-ghost" type="button" onclick="resetSearch()">초기화</button>
            <button class="btn btn-primary" type="button" onclick="searchReservations(1)">검색</button>
          </div>
        </div>
      </div>

      <!-- TABLE : display:block 고정, tbody로만 상태 제어 -->
      <div class="card table-card fade-up">
        <div class="table-topbar">
          <h2>예약 목록</h2>
          <button class="btn btn-ghost btn-sm" type="button" onclick="searchReservations(1)">새로고침</button>
        </div>
        <div class="table-responsive">
          <table>
            <thead>
            <tr>
              <th>예약번호</th>
              <th>숙소 / 객실</th>
              <th>예약자</th>
              <th>이용일</th>
              <th class="right">결제금액</th>
              <th class="right">환불금액</th>
              <th>예약상태</th>
              <th>결제상태</th>
              <th></th>
            </tr>
            </thead>
            <tbody id="reservationTbody">
              <tr>
                <td colspan="9" style="text-align:center; padding:50px 0; color:var(--muted);">
                  상단의 검색 조건을 설정한 후 <strong>[검색]</strong> 버튼을 눌러주세요.
                </td>
              </tr>
            </tbody>
          </table>
        </div>
        <div class="pagination" id="pagination"></div>
      </div>
    </main>
  </div>
</div>

<!-- DETAIL MODAL -->
<div id="detailModal" class="modal-overlay">
  <div class="modal-content">
    <div class="receipt-body">
      <div class="receipt-header">
        <div>
          <h2>예약 상세</h2>
          <div class="reservation-sub" id="modalReservationId">-</div>
        </div>
        <span class="badge badge-done" id="modalStatusBadge">-</span>
      </div>

      <div class="receipt-main">
        <div class="r-section">
          <h4>예약 정보</h4>
          <div class="receipt-info-list">
            <div class="receipt-info-row"><strong>예약자</strong><span id="modalMemberName">-</span></div>
            <div class="receipt-info-row"><strong>숙소명</strong><span id="modalPlaceName">-</span></div>
            <div class="receipt-info-row"><strong>객실명</strong><span id="modalRoomName">-</span></div>
            <div class="receipt-info-row"><strong>파트너사</strong><span id="modalPartnerName">-</span></div>
            <div class="receipt-info-row"><strong>체크인</strong><span id="modalCheckIn">-</span></div>
            <div class="receipt-info-row"><strong>체크아웃</strong><span id="modalCheckOut">-</span></div>
            <div class="receipt-info-row"><strong>인원수</strong><span id="modalGuestCount">-</span></div>
            <div class="receipt-info-row"><strong>요청사항</strong><span id="modalRequest">-</span></div>
          </div>
        </div>

        <div class="r-section">
          <h4>결제 / 정산 정보</h4>
          <div class="price-table">
            <div class="price-row">
              <span>총 결제금액</span>
              <span id="modalAmount">0원</span>
            </div>
            <div class="price-row" style="flex-direction: column; gap: 6px;">
              <div class="coupon-section-label">쿠폰 할인</div>
              <div id="modalCouponList"></div>
            </div>
            <div class="price-row">
              <span>포인트 할인</span>
              <span id="modalPointDiscount">0원</span>
            </div>
            <div class="price-row">
              <span>환불금액</span>
              <span id="modalRefundAmount">0원</span>
            </div>
            <div class="price-row">
              <span>플랫폼 수수료율</span>
              <span id="modalCommissionRate">0%</span>
            </div>
            <div class="price-row">
              <span>결제상태</span>
              <span id="modalPaymentStatus">-</span>
            </div>
            <div class="price-total">
              <span>실제 결제금액</span>
              <span id="modalSettlementTarget">0원</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div class="modal-actions">
      <button class="btn-full btn-ghost" type="button" onclick="closeDetailModal()">닫기</button>
      <div class="status-action-wrap">
        <button class="btn-full btn-ghost" type="button" onclick="changeReservationStatus('SUCCESS')">예약확정</button>
        <button class="btn-full btn-primary" type="button" onclick="changeReservationStatus('CANCELED')">취소처리</button>
      </div>
    </div>
  </div>
</div>

<script>
  const contextPath = '${pageContext.request.contextPath}';
</script>
<script src="${pageContext.request.contextPath}/dist/js/admin/reservation.js"></script>
</body>
</html>
