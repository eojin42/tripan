<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<%@ taglib prefix="fn"  uri="jakarta.tags.functions"%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>TripanSuper &mdash; 정산 상세</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/admin.css">
  <style>
    /* ── 상단 파트너 헤더 ── */
    .partner-header {
      display:flex; align-items:center; gap:16px;
      padding:22px 28px; background:#fff;
      border:1.5px solid var(--border); border-radius:16px;
      margin-bottom:22px;
    }
    .ph-avatar {
      width:52px; height:52px; border-radius:14px;
      background:var(--primary-10); display:flex; align-items:center;
      justify-content:center; font-size:22px; flex-shrink:0;
    }
    .ph-info { flex:1; min-width:0; }
    .ph-info h2 { font-size:20px; font-weight:900; margin:0 0 4px; }
    .ph-info p  { font-size:13px; color:var(--muted); margin:0; }
    .ph-actions { display:flex; gap:8px; flex-shrink:0; }

    /* ── 정산 요약 KPI ── */
    .summary-grid {
      display:grid; grid-template-columns:repeat(5,1fr); gap:12px; margin-bottom:22px;
    }
    .s-kpi { background:#fff; border:1.5px solid var(--border); border-radius:12px; padding:16px 18px; }
    .s-kpi-label { font-size:11px; font-weight:700; color:var(--muted); text-transform:uppercase; letter-spacing:.05em; margin-bottom:6px; }
    .s-kpi-value { font-size:18px; font-weight:900; font-variant-numeric:tabular-nums; }
    .s-kpi-sub   { font-size:11px; color:var(--muted); margin-top:4px; }

    /* ── 공식 설명 박스 ── */
    .formula-box {
      background:#F8FAFC; border:1.5px solid var(--border); border-radius:12px;
      padding:14px 20px; margin-bottom:22px;
      display:flex; align-items:center; gap:8px; font-size:13px; flex-wrap:wrap;
    }
    .formula-item { display:flex; align-items:center; gap:6px; }
    .formula-chip {
      padding:3px 10px; border-radius:6px; font-size:12px; font-weight:700;
    }
    .fc-gmv   { background:#EFF6FF; color:#1D4ED8; }
    .fc-comm  { background:#FEF2F2; color:#DC2626; }
    .fc-coupon{ background:#FFF7ED; color:#C2410C; }
    .fc-net   { background:#F0FDF4; color:#15803D; }
    .formula-op { font-size:16px; color:var(--muted); font-weight:700; }

    /* ── 숙소 카드 ── */
    .place-card {
      border:1.5px solid var(--border); border-radius:16px;
      margin-bottom:16px; overflow:hidden;
      transition:box-shadow .18s;
    }
    .place-card:hover { box-shadow:0 4px 20px rgba(0,0,0,.08); }

    .place-head {
      display:flex; align-items:center; gap:14px;
      padding:18px 22px; cursor:pointer;
      background:#fff; transition:background .12s;
    }
    .place-head:hover { background:var(--bg,#F9FAFB); }

    .place-icon {
      width:42px; height:42px; border-radius:11px;
      background:var(--bg,#F3F4F6); display:flex; align-items:center;
      justify-content:center; font-size:18px; flex-shrink:0;
    }
    .place-meta { flex:1; min-width:0; }
    .place-meta h3 { font-size:15px; font-weight:800; margin:0 0 3px; color:var(--text); }
    .place-meta p  { font-size:12px; color:var(--muted); margin:0; }

    .place-amounts {
      display:flex; align-items:center; gap:14px; flex-shrink:0;
    }
    .pa-item { text-align:right; }
    .pa-label { font-size:11px; color:var(--muted); font-weight:600; margin-bottom:2px; }
    .pa-value { font-size:14px; font-weight:800; font-variant-numeric:tabular-nums; }

    .badge { display:inline-flex; align-items:center; padding:4px 10px; border-radius:20px; font-size:12px; font-weight:700; white-space:nowrap; }
    .badge-wait    { background:rgba(245,158,11,.12); color:#D97706; }
    .badge-done    { background:rgba(16,185,129,.12);  color:#059669; }
    .badge-partial { background:rgba(59,110,248,.10);  color:#3B6EF8; }

    .fee-chip { background:rgba(59,110,248,.10); color:#3B6EF8; padding:3px 9px; border-radius:20px; font-size:11px; font-weight:700; }
    .chevron  { font-size:11px; color:var(--muted); transition:transform .22s; }
    .chevron.open { transform:rotate(180deg); }

    /* ── 숙소 상세 (아코디언) ── */
    .place-detail {
      border-top:1px solid var(--border-light,#F3F4F6);
      background:var(--bg,#F9FAFB);
      max-height:0; overflow:hidden;
      transition:max-height .35s ease, padding .3s;
      padding:0 22px;
    }
    .place-detail.open { max-height:1200px; padding:18px 22px; }

    /* 비용 분해 그리드 */
    .cost-grid {
      display:grid; grid-template-columns:repeat(5,1fr); gap:10px; margin-bottom:18px;
    }
    .cost-item {
      background:#fff; border-radius:10px; padding:12px 14px;
      border:1px solid var(--border-light,#F3F4F6);
    }
    .cost-label { font-size:11px; color:var(--muted); font-weight:600; margin-bottom:4px; }
    .cost-value { font-size:14px; font-weight:800; font-variant-numeric:tabular-nums; }
    .cv-gmv    { color:var(--text); }
    .cv-comm   { color:#DC2626; }
    .cv-coupon { color:#C2410C; }
    .cv-net    { color:#15803D; }
    .cv-orders { color:var(--primary,#3B6EF8); }

    /* 예약 건 테이블 */
    .order-table-wrap { overflow-x:auto; }
    .o-table { width:100%; border-collapse:collapse; }
    .o-table thead tr { border-bottom:1.5px solid var(--border); }
    .o-table th {
      padding:8px 12px; font-size:11px; font-weight:700;
      color:var(--muted); text-transform:uppercase; letter-spacing:.03em; text-align:left;
      white-space:nowrap;
    }
    .o-table td { padding:10px 12px; font-size:13px; border-bottom:1px solid var(--border-light,#F3F4F6); }
    .o-table tbody tr:last-child td { border-bottom:none; }
    .o-table tbody tr:hover { background:rgba(59,110,248,.03); }
    .num { font-variant-numeric:tabular-nums; font-weight:700; }
    .text-danger { color:#DC2626; }
    .text-warn   { color:#C2410C; }
    .text-success{ color:#15803D; }
    .text-muted  { color:var(--muted); }

    /* 합계 행 */
    .o-table tfoot tr { border-top:2px solid var(--border); background:#F8FAFC; }
    .o-table tfoot td { padding:10px 12px; font-size:13px; font-weight:800; }

    /* 숙소 하단 액션 */
    .place-foot {
      display:flex; align-items:center; justify-content:space-between;
      padding-top:14px; margin-top:14px;
      border-top:1px solid var(--border-light,#F3F4F6);
    }
    .place-foot-info { font-size:12px; color:var(--muted); }

    /* 버튼 */
    .btn-approve-place {
      height:38px; padding:0 20px; border-radius:9px; font-size:13px; font-weight:800;
      border:none; cursor:pointer; background:var(--primary,#3B6EF8); color:#fff;
      transition:opacity .15s, transform .1s; display:inline-flex; align-items:center; gap:6px;
    }
    .btn-approve-place:hover { opacity:.85; transform:translateY(-1px); }
    .btn-approve-place:disabled { background:var(--border); color:var(--muted); cursor:default; transform:none; }

    .btn-excel-place {
      height:38px; padding:0 16px; border-radius:9px; font-size:13px; font-weight:700;
      border:1.5px solid #059669; background:transparent; color:#059669; cursor:pointer;
      transition:all .15s; display:inline-flex; align-items:center; gap:6px;
    }
    .btn-excel-place:hover { background:#059669; color:#fff; }

    .btn-sm-ghost {
      height:32px; padding:0 12px; border-radius:8px; font-size:12px; font-weight:700;
      border:1.5px solid var(--border); background:transparent; color:var(--muted);
      cursor:pointer; transition:all .15s;
    }
    .btn-sm-ghost:hover { border-color:#94A3B8; color:var(--text); }

    /* 전체 하단 액션바 */
    .bulk-action-bar {
      position:sticky; bottom:0;
      background:#fff; border-top:1.5px solid var(--border);
      padding:14px 28px; display:flex; align-items:center; justify-content:space-between;
      box-shadow:0 -4px 16px rgba(0,0,0,.06); z-index:100; margin:24px -28px -28px;
      border-radius:0 0 16px 16px;
    }
    .bar-info { font-size:13px; color:var(--muted); }
    .bar-info strong { color:var(--text); font-size:14px; }
    .bar-actions { display:flex; gap:10px; }
    .btn-bulk-approve {
      height:42px; padding:0 22px; border-radius:11px; font-size:14px; font-weight:800;
      border:none; cursor:pointer; background:#111; color:#fff;
      display:inline-flex; align-items:center; gap:8px; transition:opacity .15s, transform .1s;
    }
    .btn-bulk-approve:hover { opacity:.86; transform:translateY(-1px); }
    .btn-bulk-approve:disabled { background:var(--border); color:var(--muted); cursor:default; transform:none; }
    .btn-excel-all {
      height:42px; padding:0 20px; border-radius:11px; font-size:14px; font-weight:700;
      border:1.5px solid #059669; background:transparent; color:#059669; cursor:pointer;
      display:inline-flex; align-items:center; gap:8px; transition:all .15s;
    }
    .btn-excel-all:hover { background:#059669; color:#fff; }

    /* 뒤로가기 */
    .back-link {
      display:inline-flex; align-items:center; gap:6px;
      font-size:13px; font-weight:700; color:var(--muted);
      text-decoration:none; margin-bottom:16px;
      transition:color .15s;
    }
    .back-link:hover { color:var(--text); }

    /* 쿠폰 없음 표시 */
    .no-coupon { color:var(--muted); font-size:12px; }

    /* 토스트 */
    .toast { position:fixed; bottom:28px; left:50%; transform:translateX(-50%) translateY(16px); background:#111; color:#fff; padding:12px 22px; border-radius:14px; font-size:13px; font-weight:600; z-index:2000; opacity:0; transition:opacity .22s, transform .22s; pointer-events:none; white-space:nowrap; }
    .toast.show { opacity:1; transform:translateX(-50%) translateY(0); }
  </style>
</head>
<body>
<div class="admin-layout">
  <jsp:include page="../layout/sidebar.jsp"><jsp:param name="activePage" value="settlement"/></jsp:include>
  <div class="main-wrapper">
    <jsp:include page="../layout/header.jsp" />

    <main class="main-content">

      <!-- 뒤로가기 -->
      <a href="${pageContext.request.contextPath}/admin/settlement/main" class="back-link fade-up">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg>
        정산 목록으로
      </a>

      <!-- 파트너 헤더 -->
      <div class="partner-header fade-up">
        <div class="ph-avatar">&#128102;</div>
        <div class="ph-info">
          <h2>${partnerNickname} <span style="font-size:14px;font-weight:600;color:var(--muted);">(${partnerLoginId})</span></h2>
          <p>파트너 ID: ${memberId} &nbsp;&middot;&nbsp; 정산월: <strong>${settlementMonth}</strong> &nbsp;&middot;&nbsp; 숙소 ${fn:length(details)}개</p>
        </div>
        <div class="ph-actions">
          <button class="btn-excel-all" onclick="downloadPartnerCsv(${memberId}, '${settlementMonth}')">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
            전체 CSV
          </button>
        </div>
      </div>

      <!-- 파트너 전체 합산 KPI -->
      <div class="summary-grid fade-up">
        <div class="s-kpi">
          <div class="s-kpi-label">총 결제액 (GMV)</div>
          <div class="s-kpi-value">
            <fmt:formatNumber value="${totalGmv}" pattern="#,###"/>원
          </div>
          <div class="s-kpi-sub">전체 숙소 합산</div>
        </div>
        <div class="s-kpi">
          <div class="s-kpi-label">수수료</div>
          <div class="s-kpi-value" style="color:#DC2626">
            - <fmt:formatNumber value="${totalCommission}" pattern="#,###"/>원
          </div>
          <div class="s-kpi-sub">플랫폼 수수료</div>
        </div>
        <div class="s-kpi">
          <div class="s-kpi-label">쿠폰 파트너 부담</div>
          <div class="s-kpi-value" style="color:#C2410C">
            - <fmt:formatNumber value="${totalCouponPartner}" pattern="#,###"/>원
          </div>
          <div class="s-kpi-sub">플랫폼 부담: <fmt:formatNumber value="${totalCouponPlatform}" pattern="#,###"/>원</div>
        </div>
        <div class="s-kpi">
          <div class="s-kpi-label">최종 지급액 (Net)</div>
          <div class="s-kpi-value" style="color:#15803D">
            <fmt:formatNumber value="${totalNetPayout}" pattern="#,###"/>원
          </div>
          <div class="s-kpi-sub">파트너 수취액</div>
        </div>
        <div class="s-kpi">
          <div class="s-kpi-label">정산 진행</div>
          <div class="s-kpi-value" style="font-size:16px;">${approvedPlaceCount} / ${fn:length(details)}</div>
          <div class="s-kpi-sub">숙소 승인 완료</div>
        </div>
      </div>

      <!-- 정산 공식 안내 -->
      <div class="formula-box fade-up">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#6B7280" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
        <span style="font-size:12px;color:var(--muted);font-weight:700;">정산 공식</span>
        <div class="formula-item"><span class="formula-chip fc-gmv">총 결제액</span></div>
        <span class="formula-op">-</span>
        <div class="formula-item"><span class="formula-chip fc-comm">수수료 (숙소별 요율 적용)</span></div>
        <span class="formula-op">-</span>
        <div class="formula-item"><span class="formula-chip fc-coupon">쿠폰 파트너 부담분</span></div>
        <span class="formula-op">=</span>
        <div class="formula-item"><span class="formula-chip fc-net">최종 지급액</span></div>
      </div>

      <!-- 숙소별 정산 카드 목록 -->
      <c:forEach var="d" items="${details}" varStatus="vs">
        <div class="place-card fade-up" id="placeCard_${d.placeId}">

          <!-- 카드 헤더 (클릭 시 아코디언) -->
          <div class="place-head" onclick="togglePlace(${d.placeId})">
            <div class="place-icon">&#127968;</div>
            <div class="place-meta">
              <h3>${d.placeName}
                <span class="fee-chip" style="margin-left:6px;">수수료 <fmt:formatNumber value="${d.commissionRate}" pattern="#.##"/>%</span>
              </h3>
              <p>${d.placeType} &middot; ${d.placeRegion} &middot; #${d.placeId} &middot; 예약 ${d.orderCount}건</p>
            </div>
            <div class="place-amounts">
              <div class="pa-item">
                <div class="pa-label">총 결제액</div>
                <div class="pa-value"><fmt:formatNumber value="${d.totalGmv}" pattern="#,###"/>원</div>
              </div>
              <div class="pa-item">
                <div class="pa-label">수수료</div>
                <div class="pa-value text-danger">-<fmt:formatNumber value="${d.totalCommission}" pattern="#,###"/>원</div>
              </div>
              <div class="pa-item">
                <div class="pa-label">쿠폰부담</div>
                <div class="pa-value text-warn">-<fmt:formatNumber value="${d.totalCouponPartner}" pattern="#,###"/>원</div>
              </div>
              <div class="pa-item">
                <div class="pa-label">지급액</div>
                <div class="pa-value text-success"><fmt:formatNumber value="${d.totalNetPayout}" pattern="#,###"/>원</div>
              </div>
              <c:choose>
                <c:when test="${d.settlementStatus == 'APPROVED'}">
                  <span class="badge badge-done">승인완료</span>
                </c:when>
                <c:otherwise>
                  <span class="badge badge-wait">대기중</span>
                </c:otherwise>
              </c:choose>
              <span class="chevron" id="chevron_${d.placeId}">&#9660;</span>
            </div>
          </div>

          <!-- 아코디언 상세 -->
          <div class="place-detail" id="detail_${d.placeId}">

            <!-- 비용 분해 요약 -->
            <div class="cost-grid">
              <div class="cost-item">
                <div class="cost-label">총 결제액 (GMV)</div>
                <div class="cost-value cv-gmv"><fmt:formatNumber value="${d.totalGmv}" pattern="#,###"/>원</div>
              </div>
              <div class="cost-item">
                <div class="cost-label">수수료 (<fmt:formatNumber value="${d.commissionRate}" pattern="#.##"/>%)</div>
                <div class="cost-value cv-comm">- <fmt:formatNumber value="${d.totalCommission}" pattern="#,###"/>원</div>
              </div>
              <div class="cost-item">
                <div class="cost-label">쿠폰 파트너 부담</div>
                <div class="cost-value cv-coupon">- <fmt:formatNumber value="${d.totalCouponPartner}" pattern="#,###"/>원</div>
                <div class="cost-label" style="margin-top:4px;">플랫폼 부담: <fmt:formatNumber value="${d.totalCouponPlatform}" pattern="#,###"/>원</div>
              </div>
              <div class="cost-item" style="border:1.5px solid #BBF7D0;">
                <div class="cost-label">최종 지급액 (Net)</div>
                <div class="cost-value cv-net"><fmt:formatNumber value="${d.totalNetPayout}" pattern="#,###"/>원</div>
              </div>
              <div class="cost-item">
                <div class="cost-label">예약 건수</div>
                <div class="cost-value cv-orders">${d.orderCount}건</div>
              </div>
            </div>

            <!-- 예약 건별 테이블 -->
            <div class="order-table-wrap">
              <table class="o-table">
                <thead>
                  <tr>
                    <th>주문번호</th>
                    <th>예약일</th>
                    <th>예약자</th>
                    <th>총금액</th>
                    <th>쿠폰할인</th>
                    <th style="color:#C2410C;">↳ 파트너 부담</th>
                    <th style="color:#6B7280;">↳ 플랫폼 부담</th>
                    <th>포인트할인</th>
                    <th>실결제액</th>
                    <th style="color:#DC2626;">수수료</th>
                    <th style="color:#15803D; font-weight:900;">파트너 수취액</th>
                    <th>결제상태</th>
                  </tr>
                </thead>
                <tbody>
                  <c:forEach var="o" items="${d.orders}" varStatus="os">
                    <tr>
                      <td style="font-size:12px; color:var(--muted);">${o.orderId}</td>
                      <td><fmt:formatDate value="${o.orderDate}" pattern="MM-dd"/></td>
                      <td>${o.guestNickname}</td>
                      <td class="num"><fmt:formatNumber value="${o.totalAmount}" pattern="#,###"/></td>
                      <td class="num text-warn">
                        <c:choose>
                          <c:when test="${o.couponDiscount > 0}">- <fmt:formatNumber value="${o.couponDiscount}" pattern="#,###"/></c:when>
                          <c:otherwise><span class="no-coupon">-</span></c:otherwise>
                        </c:choose>
                      </td>
                      <td class="num text-warn">
                        <c:choose>
                          <c:when test="${o.couponPartnerAmt > 0}">- <fmt:formatNumber value="${o.couponPartnerAmt}" pattern="#,###"/></c:when>
                          <c:otherwise><span class="no-coupon">-</span></c:otherwise>
                        </c:choose>
                      </td>
                      <td class="num text-muted">
                        <c:choose>
                          <c:when test="${o.couponPlatformAmt > 0}">- <fmt:formatNumber value="${o.couponPlatformAmt}" pattern="#,###"/></c:when>
                          <c:otherwise><span class="no-coupon">-</span></c:otherwise>
                        </c:choose>
                      </td>
                      <td class="num text-muted">
                        <c:choose>
                          <c:when test="${o.pointDiscount > 0}">- <fmt:formatNumber value="${o.pointDiscount}" pattern="#,###"/></c:when>
                          <c:otherwise><span class="no-coupon">-</span></c:otherwise>
                        </c:choose>
                      </td>
                      <td class="num"><fmt:formatNumber value="${o.realTotalAmount}" pattern="#,###"/></td>
                      <td class="num text-danger">- <fmt:formatNumber value="${o.commissionAmount}" pattern="#,###"/></td>
                      <td class="num text-success" style="font-weight:900;"><fmt:formatNumber value="${o.partnerPayout}" pattern="#,###"/></td>
                      <td>
                        <c:choose>
                          <c:when test="${o.paymentStatus == 'PAID'}"><span class="badge badge-done" style="font-size:11px;">결제완료</span></c:when>
                          <c:when test="${o.paymentStatus == 'CANCELLED'}"><span class="badge" style="background:rgba(239,68,68,.10);color:#DC2626;font-size:11px;">취소</span></c:when>
                          <c:otherwise><span class="badge" style="background:var(--bg);color:var(--muted);font-size:11px;">${o.paymentStatus}</span></c:otherwise>
                        </c:choose>
                      </td>
                    </tr>
                  </c:forEach>
                  <c:if test="${empty d.orders}">
                    <tr><td colspan="12" style="text-align:center;padding:24px;color:var(--muted);">예약 내역이 없습니다.</td></tr>
                  </c:if>
                </tbody>
                <!-- 합계 행 -->
                <c:if test="${not empty d.orders}">
                  <tfoot>
                    <tr>
                      <td colspan="3">합계 (${d.orderCount}건)</td>
                      <td class="num"><fmt:formatNumber value="${d.totalGmv}" pattern="#,###"/></td>
                      <td></td>
                      <td class="num text-warn">- <fmt:formatNumber value="${d.totalCouponPartner}" pattern="#,###"/></td>
                      <td class="num text-muted">- <fmt:formatNumber value="${d.totalCouponPlatform}" pattern="#,###"/></td>
                      <td></td>
                      <td class="num"><fmt:formatNumber value="${d.totalGmv}" pattern="#,###"/></td>
                      <td class="num text-danger">- <fmt:formatNumber value="${d.totalCommission}" pattern="#,###"/></td>
                      <td class="num text-success" style="font-weight:900;"><fmt:formatNumber value="${d.totalNetPayout}" pattern="#,###"/></td>
                      <td></td>
                    </tr>
                  </tfoot>
                </c:if>
              </table>
            </div>

            <!-- 숙소별 액션 -->
            <div class="place-foot">
              <div class="place-foot-info">
                숙소 ID: <strong>#${d.placeId}</strong>
                &nbsp;&middot;&nbsp; 수수료율: <strong><fmt:formatNumber value="${d.commissionRate}" pattern="#.##"/>%</strong>
              </div>
              <div style="display:flex; gap:8px;">
                <button class="btn-excel-place" onclick="downloadPlaceCsv(${d.placeId}, '${settlementMonth}')">
                  <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
                  숙소 CSV
                </button>
                <c:choose>
                  <c:when test="${d.settlementStatus == 'APPROVED'}">
                    <button class="btn-approve-place" disabled>&#10003; 승인 완료</button>
                  </c:when>
                  <c:otherwise>
                    <button class="btn-approve-place"
                            id="approveBtn_${d.placeId}"
                            onclick="approvePlace(${d.placeId}, '${settlementMonth}', this)">
                      &#10003; 이 숙소 정산 승인
                    </button>
                  </c:otherwise>
                </c:choose>
              </div>
            </div>

          </div><!-- /place-detail -->
        </div><!-- /place-card -->
      </c:forEach>

      <c:if test="${empty details}">
        <div class="card" style="text-align:center; padding:60px; color:var(--muted);">
          정산 내역이 없습니다.
        </div>
      </c:if>

      <!-- 하단 액션바 (sticky) -->
      <div class="bulk-action-bar">
        <div class="bar-info">
          파트너: <strong>${partnerNickname}</strong> &nbsp;&middot;&nbsp;
          정산월: <strong>${settlementMonth}</strong> &nbsp;&middot;&nbsp;
          승인: <strong id="barApprovedCount">${approvedPlaceCount}</strong> / ${fn:length(details)}개 숙소
        </div>
        <div class="bar-actions">
          <button class="btn-excel-all" onclick="downloadPartnerCsv('${memberId}', '${settlementMonth}')">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
            전체 CSV 다운로드
          </button>
          <button class="btn-bulk-approve" id="bulkApproveBtn"
                  onclick="approveAll('${memberId}', '${settlementMonth}')"
                  <c:if test="${approvedPlaceCount >= fn:length(details)}">disabled</c:if>>
            &#10003;&nbsp; 미승인 전체 승인
          </button>
        </div>
      </div>

    </main>
  </div>
</div>

<div class="toast" id="toast"></div>

<script src="${pageContext.request.contextPath}/dist/js/admin/settlementDetail.js"></script>
</body>
</html>
