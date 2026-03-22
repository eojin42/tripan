<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>TripanSuper — 플랫폼 정산</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/admin.css">
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
  <style>
    .kpi-grid { display:grid; grid-template-columns:repeat(4,1fr); gap:14px; margin-bottom:22px; }
    .kpi-card { padding:20px 22px; border-radius:14px; border:1.5px solid var(--border); background:#fff; }
    .kpi-eyebrow { font-size:11px; font-weight:700; text-transform:uppercase; letter-spacing:.06em; color:var(--muted); margin-bottom:8px; }
    .kpi-val { font-size:24px; font-weight:900; font-variant-numeric:tabular-nums; line-height:1; margin-bottom:6px; }
    .kpi-footer { font-size:12px; color:var(--muted); display:flex; align-items:center; gap:5px; }
    .trend-up   { color:#10B981; font-weight:700; }
    .trend-down { color:#EF4444; font-weight:700; }

    .alert-banner { display:flex; align-items:center; gap:14px; background:rgba(245,158,11,.07); border:1.5px solid rgba(245,158,11,.28); border-radius:14px; padding:15px 22px; margin-bottom:22px; }
    .alert-icon { font-size:20px; flex-shrink:0; }
    .alert-body { flex:1; }
    .alert-body strong { font-size:14px; color:var(--text); }
    .alert-body p { margin:2px 0 0; font-size:12px; color:var(--muted); }
    .btn-link { height:36px; padding:0 16px; border-radius:9px; font-size:12px; font-weight:800; border:none; cursor:pointer; background:#111; color:#fff; white-space:nowrap; text-decoration:none; display:inline-flex; align-items:center; transition:opacity .15s; }
    .btn-link:hover { opacity:.82; }

    .breakdown-wrap { padding:20px 24px; border-radius:14px; border:1.5px solid var(--border); background:#fff; margin-bottom:22px; }
    .bd-title { font-size:13px; font-weight:800; margin-bottom:14px; display:flex; align-items:center; justify-content:space-between; }
    .bd-bar { height:18px; border-radius:9px; overflow:hidden; display:flex; gap:2px; margin-bottom:12px; }
    .bd-seg { height:100%; transition:width .5s cubic-bezier(.4,0,.2,1); }
    .bd-legend { display:flex; gap:18px; flex-wrap:wrap; }
    .bd-item { display:flex; align-items:center; gap:5px; font-size:12px; color:var(--muted); }
    .bd-dot { width:9px; height:9px; border-radius:2px; flex-shrink:0; }
    .bd-item b { color:var(--text); font-variant-numeric:tabular-nums; }

    .two-col { display:grid; grid-template-columns:320px 1fr; gap:16px; margin-bottom:22px; }

    .waterfall-card { padding:22px 24px; border-radius:14px; border:1.5px solid var(--border); background:#fff; }
    .waterfall-card h2 { font-size:13px; font-weight:800; margin:0 0 16px; }
    .wf-row { display:flex; align-items:center; gap:10px; margin-bottom:8px; }
    .wf-label { font-size:12px; color:var(--muted); width:95px; text-align:right; flex-shrink:0; }
    .wf-bar-outer { flex:1; height:26px; background:var(--bg,#F3F4F6); border-radius:6px; overflow:hidden; }
    .wf-bar-inner { height:100%; border-radius:6px; display:flex; align-items:center; padding-left:8px; font-size:11px; font-weight:800; color:#fff; transition:width .6s cubic-bezier(.4,0,.2,1); white-space:nowrap; }
    .wf-amt { font-size:12px; font-weight:800; font-variant-numeric:tabular-nums; width:75px; text-align:right; flex-shrink:0; }
    .wf-divider { border:none; border-top:1.5px dashed var(--border); margin:10px 0; }
    .wf-total .wf-label { font-weight:800; color:var(--text); }
    .wf-total .wf-amt { font-size:14px; color:#10B981; }

    .chart-card { padding:22px 24px; border-radius:14px; border:1.5px solid var(--border); background:#fff; }
    .chart-card h2 { font-size:13px; font-weight:800; margin:0 0 4px; }
    .chart-sub { font-size:11px; color:var(--muted); margin-bottom:14px; }
    .chart-wrap { position:relative; height:210px; }

    .table-card { padding:22px 26px; border-radius:14px; border:1.5px solid var(--border); background:#fff; margin-bottom:22px; }
    .table-header { display:flex; align-items:center; justify-content:space-between; margin-bottom:16px; }
    .table-header h2 { font-size:13px; font-weight:800; margin:0; }
    table { width:100%; border-collapse:collapse; }
    thead tr { border-bottom:2px solid var(--border); }
    th { padding:9px 13px; font-size:11px; font-weight:700; color:var(--muted); text-transform:uppercase; letter-spacing:.04em; text-align:left; white-space:nowrap; }
    td { padding:12px 13px; border-bottom:1px solid var(--border-light,#F3F4F6); font-size:13px; vertical-align:middle; }
    tbody tr:last-child td { border-bottom:none; }
    tbody tr:hover { background:var(--hover-bg,#F9FAFB); }
    .num { font-variant-numeric:tabular-nums; font-weight:700; }
    .text-blue   { color:#3B6EF8; }
    .text-green  { color:#10B981; }
    .text-purple { color:#8B5CF6; }
    .text-amber  { color:#D97706; }
    .text-muted  { color:var(--muted); }
    .badge { display:inline-flex; align-items:center; padding:3px 9px; border-radius:20px; font-size:11px; font-weight:700; white-space:nowrap; }
    .badge-done    { background:rgba(16,185,129,.12); color:#059669; }
    .badge-partial { background:rgba(59,110,248,.10); color:#3B6EF8; }
    .badge-wait    { background:rgba(245,158,11,.12);  color:#D97706; }
    .tfoot-row td { font-weight:800; background:#F8FAFC; border-top:2px solid var(--border); }

    .filter-select { height:32px; padding:0 10px; border:1.5px solid var(--border); border-radius:8px; font-size:12px; font-weight:600; color:var(--text); background:#fff; outline:none; cursor:pointer; font-family:inherit; }
  </style>
</head>
<body>
<div class="admin-layout">
  <jsp:include page="../layout/sidebar.jsp"><jsp:param name="activePage" value="platform-settlement"/></jsp:include>
  <div class="main-wrapper">
    <jsp:include page="../layout/header.jsp" />
    <main class="main-content">

      <div class="page-header fade-up">
        <div>
          <h1>플랫폼 매출 현황</h1>
          <p>월별 수익 구조와 파트너 정산 현황을 조회합니다.</p>
        </div>
        <div style="display:flex;gap:8px;align-items:center;">
          <select class="filter-select" id="filterYear"><option value="2026">2026년</option><option value="2025">2025년</option></select>
          <select class="filter-select" id="filterMonth">
            <option value="">연간 전체</option>
            <option value="03" selected>3월</option>
            <option value="02">2월</option>
            <option value="01">1월</option>
          </select>
        </div>
      </div>

      <!-- 미정산 배너 -->
      <div class="alert-banner fade-up">
        <div class="alert-icon">⚠️</div>
        <div class="alert-body">
          <strong>미정산 파트너 <span id="pendingCount">3</span>개 &nbsp;·&nbsp; 대기 금액 <span id="pendingAmt">₩82,000,000</span></strong>
          <p>정산 승인이 완료되지 않은 파트너가 있습니다.</p>
        </div>
        <a href="${pageContext.request.contextPath}/admin/settlement/partner/main" class="btn-link">파트너 정산 관리 →</a>
      </div>

      <!-- KPI -->
      <div class="kpi-grid fade-up">
        <div class="kpi-card">
          <div class="kpi-eyebrow">총 거래액 (GMV)</div>
          <div class="kpi-val text-blue" id="kpiGmv">₩0</div>
          <div class="kpi-footer"><span class="trend-up" id="kpiGmvTrend">-</span>&nbsp;vs 전월</div>
        </div>
        <div class="kpi-card">
          <div class="kpi-eyebrow">플랫폼 순이익</div>
          <div class="kpi-val text-green" id="kpiProfit">₩0</div>
          <div class="kpi-footer" style="font-size:11px;">GMV − 파트너지급 − 쿠폰 − 포인트</div>
        </div>
        <div class="kpi-card">
          <div class="kpi-eyebrow">수수료 수익</div>
          <div class="kpi-val text-purple" id="kpiCommission">₩0</div>
          <div class="kpi-footer"><span id="kpiCommissionRate" style="font-weight:700;">-</span>&nbsp;평균 수수료율</div>
        </div>
        <div class="kpi-card">
          <div class="kpi-eyebrow">쿠폰 + 포인트 사용</div>
          <div class="kpi-val text-amber" id="kpiDiscount">₩0</div>
          <div class="kpi-footer"><span id="kpiCoupon">쿠폰 ₩0</span>&nbsp;|&nbsp;<span id="kpiPoint">포인트 ₩0</span></div>
        </div>
      </div>

      <!-- 워터폴 + 차트 -->
      <div class="two-col fade-up">
        <div class="waterfall-card">
          <h2 id="waterfallTitle">💹 수익 흐름</h2>
          <div class="wf-row">
            <div class="wf-label">총 거래액</div>
            <div class="wf-bar-outer"><div class="wf-bar-inner" id="wbGmv" style="width:100%;background:#3B6EF8;">GMV</div></div>
            <div class="wf-amt text-blue" id="waGmv">₩0</div>
          </div>
          <div class="wf-row">
            <div class="wf-label">− 파트너 지급</div>
            <div class="wf-bar-outer"><div class="wf-bar-inner" id="wbPayout" style="width:65%;background:#94A3B8;"></div></div>
            <div class="wf-amt text-muted" id="waPayout">₩0</div>
          </div>
          <div class="wf-row">
            <div class="wf-label">− 쿠폰 할인</div>
            <div class="wf-bar-outer"><div class="wf-bar-inner" id="wbCoupon" style="width:8%;background:#F59E0B;"></div></div>
            <div class="wf-amt text-amber" id="waCoupon">₩0</div>
          </div>
          <div class="wf-row">
            <div class="wf-label">− 포인트 사용</div>
            <div class="wf-bar-outer"><div class="wf-bar-inner" id="wbPoint" style="width:4%;background:#FB923C;"></div></div>
            <div class="wf-amt text-amber" id="waPoint">₩0</div>
          </div>
          <hr class="wf-divider">
          <div class="wf-row wf-total">
            <div class="wf-label">= 플랫폼 순이익</div>
            <div class="wf-bar-outer"><div class="wf-bar-inner" id="wbProfit" style="width:22%;background:#10B981;">순이익</div></div>
            <div class="wf-amt" id="waProfit">₩0</div>
          </div>
        </div>

        <div class="chart-card">
          <h2>📈 일별 수익 추이</h2>
          <div class="chart-sub">수수료 수익 vs 플랫폼 순이익 (단위: 천원)</div>
          <div class="chart-wrap"><canvas id="revenueChart"></canvas></div>
        </div>
      </div>

      <!-- 수익 분해 바 -->
      <div class="breakdown-wrap fade-up">
        <div class="bd-title">
          <span>💰 수익 구조 분해 <span style="font-size:12px;font-weight:600;color:var(--muted);" id="bdLabel"></span></span>
          <span style="font-size:12px;font-weight:600;color:var(--muted);" id="bdGmvTotal"></span><span style="font-size:11px;font-weight:600;color:var(--muted);margin-left:6px;" id="bdUnit"></span>
        </div>
        <div class="bd-bar">
          <div class="bd-seg" id="bdSegPayout"   style="background:#3B6EF8;border-radius:9px 0 0 9px;"></div>
          <div class="bd-seg" id="bdSegComm"     style="background:#8B5CF6;"></div>
          <div class="bd-seg" id="bdSegDiscount" style="background:#F59E0B;"></div>
          <div class="bd-seg" id="bdSegEtc"      style="background:#E5E7EB;border-radius:0 9px 9px 0;"></div>
        </div>
        <div class="bd-legend">
          <div class="bd-item"><div class="bd-dot" style="background:#3B6EF8;"></div>파트너 지급 <b id="bdPayout">₩0</b></div>
          <div class="bd-item"><div class="bd-dot" style="background:#8B5CF6;"></div>수수료 수익 <b id="bdComm">₩0</b></div>
          <div class="bd-item"><div class="bd-dot" style="background:#F59E0B;"></div>쿠폰+포인트 <b id="bdDiscount">₩0</b></div>
          <div class="bd-item"><div class="bd-dot" style="background:#E5E7EB;"></div>기타/미정산 <b id="bdEtc">₩0</b></div>
        </div>
      </div>

      <!-- 월별 정산 테이블 -->
      <div class="table-card fade-up">
        <div class="table-header">
          <h2>📋 월별 정산 집계</h2>
          <span style="font-size:12px;color:var(--muted);">행 클릭 시 파트너별 상세로 이동</span>
        </div>
        <table>
          <thead>
            <tr>
              <th>정산월</th>
              <th>총 GMV</th>
              <th>파트너 지급액</th>
              <th>수수료 수익</th>
              <th>쿠폰 사용</th>
              <th>포인트 사용</th>
              <th>플랫폼 순이익</th>
              <th>파트너 수</th>
              <th>정산 상태</th>
            </tr>
          </thead>
          <tbody id="settlementTbody">
          </tbody>
          <tfoot id="settlementTfoot">
          </tfoot>
        </table>
      </div>

    </main>
  </div>
</div>

<script>
  const contextPath = '${pageContext.request.contextPath}';
</script>
<script src="${pageContext.request.contextPath}/dist/js/admin/platformSettlement.js"></script>
</body>
</html>
