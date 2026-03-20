<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>TripanSuper &mdash; 파트너 정산 관리</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/admin.css">
  <style>
    .filter-row { display:flex; align-items:center; gap:10px; flex-wrap:wrap; }
    .filter-label { font-size:13px; font-weight:800; color:var(--muted); white-space:nowrap; }
    .keyword-input {
      flex:1; min-width:160px; height:38px; padding:0 14px;
      border:1.5px solid var(--border); border-radius:10px;
      font-size:13px; font-weight:600; color:var(--text);
      background:#fff; outline:none; transition:border-color .2s; font-family:inherit;
    }
    .keyword-input:focus { border-color:var(--primary); box-shadow:0 0 0 3px var(--primary-10); }
    .btn-reset {
      background:var(--bg); color:var(--muted); border:1.5px solid var(--border);
      border-radius:10px; height:38px; padding:0 14px; font-size:13px; font-weight:700;
      cursor:pointer; display:inline-flex; align-items:center; gap:5px; transition:all .15s;
    }
    .btn-reset:hover { background:#F1F5F9; color:var(--text); border-color:#94A3B8; }
    .btn-reset svg { transition:transform .35s cubic-bezier(.34,1.56,.64,1); }
    .btn-reset:hover svg { transform:rotate(-180deg); }

    .table-responsive { overflow-x:auto; }
    table { width:100%; border-collapse:collapse; }
    thead tr { border-bottom:2px solid var(--border); }
    th { padding:11px 14px; text-align:left; font-size:12px; font-weight:700; color:var(--muted); text-transform:uppercase; letter-spacing:.04em; white-space:nowrap; }
    td { padding:13px 14px; border-bottom:1px solid var(--border-light,#F3F4F6); vertical-align:middle; font-size:14px; }
    tbody tr:last-child td { border-bottom:none; }
    tbody tr:hover { background:var(--hover-bg,#F9FAFB); }

    .td-partner { display:flex; align-items:center; gap:12px; }
    .partner-info h4 { font-size:14px; font-weight:700; color:var(--text); margin:0 0 2px; }
    .partner-info p  { font-size:12px; color:var(--muted); margin:0; }

    .num { font-variant-numeric:tabular-nums; font-weight:700; }
    .amount-net { color:var(--success,#10B981); }

    .badge { display:inline-flex; align-items:center; padding:4px 10px; border-radius:20px; font-size:12px; font-weight:700; white-space:nowrap; }
    .badge-wait    { background:rgba(245,158,11,.12); color:#D97706; }
    .badge-done    { background:rgba(16,185,129,.12);  color:#059669; }
    .badge-partial { background:rgba(59,110,248,.10);  color:#3B6EF8; }

    .btn-actions { display:flex; gap:6px; justify-content:flex-end; }
    .btn-sm { height:32px; padding:0 12px; font-size:12px; font-weight:700; border-radius:8px; border:none; cursor:pointer; transition:opacity .15s, transform .1s; white-space:nowrap; }
    .btn-detail-sm  { background:transparent; border:1.5px solid var(--primary,#3B6EF8); color:var(--primary,#3B6EF8); }
    .btn-detail-sm:hover { background:var(--primary,#3B6EF8); color:#fff; }
    .btn-approve-sm { background:var(--primary,#3B6EF8); color:#fff; }
    .btn-approve-sm:hover { opacity:.85; }
    .btn-done-sm { background:transparent; border:1.5px solid var(--border); color:var(--muted); cursor:default; }
    .btn-excel-sm { background:transparent; border:1.5px solid #059669; color:#059669; }
    .btn-excel-sm:hover { background:#059669; color:#fff; }
    .no-result td { text-align:center; padding:48px; color:var(--muted); font-size:14px; }

    .toast { position:fixed; bottom:28px; left:50%; transform:translateX(-50%) translateY(16px); background:#111; color:#fff; padding:12px 22px; border-radius:14px; font-size:13px; font-weight:600; z-index:2000; opacity:0; transition:opacity .22s, transform .22s; pointer-events:none; white-space:nowrap; }
    .toast.show { opacity:1; transform:translateX(-50%) translateY(0); }
    mark { background:rgba(245,158,11,.25); color:inherit; border-radius:2px; padding:0 1px; }
  </style>
</head>
<body>
<div class="admin-layout">
  <jsp:include page="../layout/sidebar.jsp"><jsp:param name="activePage" value="settlement"/></jsp:include>
  <div class="main-wrapper">
    <jsp:include page="../layout/header.jsp" />

    <main class="main-content">

      <div class="page-header fade-up">
        <div>
          <h1>파트너 정산 관리</h1>
          <p>파트너별 숙소 매출 및 월별 정산 내역을 관리합니다.</p>
        </div>
      </div>

      <!-- KPI -->
      <div class="kpi-grid">
        <div class="card kpi-card fade-up fade-up-1">
          <div class="kpi-label">이번 달 총 거래액 (GMV)</div>
          <div class="kpi-value" id="kpiGmv">&#8361;0</div>
          <div class="kpi-sub"><span class="trend trend-up" id="kpiGmvTrend">-</span>&nbsp;vs 지난달</div>
        </div>
        <div class="card kpi-card fade-up fade-up-2">
          <div class="kpi-label">플랫폼 수수료 수익</div>
          <div class="kpi-value" style="color:var(--primary)" id="kpiCommission">&#8361;0</div>
          <div class="kpi-sub" id="kpiCommissionRate">-</div>
        </div>
        <div class="card kpi-card fade-up fade-up-3">
          <div class="kpi-label">정산 대기 금액</div>
          <div class="kpi-value" style="color:var(--warning)" id="kpiPending">&#8361;0</div>
          <div class="kpi-sub"><span class="badge badge-wait" id="kpiPendingCount">0개 파트너</span></div>
        </div>
        <div class="card kpi-card fade-up fade-up-4">
          <div class="kpi-label">정산 완료 금액</div>
          <div class="kpi-value" style="color:var(--success)" id="kpiDone">&#8361;0</div>
          <div class="kpi-sub"><span class="badge badge-done" id="kpiDoneCount">0개 파트너</span></div>
        </div>
      </div>

      <!-- 필터 -->
      <div class="card filter-card fade-up">
        <div class="filter-row">
          <div class="filter-label">정산 검색</div>
          <select class="filter-select" id="filterMonth" style="width:130px;">
            <option value="">전체 월</option>
            <option value="2026-03" selected>2026년 3월</option>
            <option value="2026-02">2026년 2월</option>
            <option value="2026-01">2026년 1월</option>
          </select>
          <select class="filter-select" id="filterStatus" style="width:130px;">
            <option value="">전체 상태</option>
            <option value="PENDING">정산 대기</option>
            <option value="PARTIAL">부분 승인</option>
            <option value="DONE">정산 완료</option>
          </select>
          <select class="filter-select" id="filterRegion" style="width:110px;">
            <option value="">전체 지역</option>
            <option value="제주">제주</option>
            <option value="서울">서울</option>
            <option value="강릉">강릉</option>
            <option value="부산">부산</option>
            <option value="경주">경주</option>
          </select>
          <input type="text" id="searchInput" class="keyword-input"
                 placeholder="파트너명 또는 ID 검색"
                 onkeyup="if(event.key==='Enter') stlLoad()">
          <button class="btn-reset" onclick="stlReset()">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="1 4 1 10 7 10"/><path d="M3.51 15a9 9 0 1 0 .49-3.51"/></svg>
            초기화
          </button>
          <button class="btn btn-primary" onclick="stlLoad()" style="display:inline-flex;align-items:center;gap:6px;">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
            검색
          </button>
        </div>
      </div>

      <!-- 테이블 -->
      <div class="card table-card fade-up">
        <div class="w-header" style="display:flex;justify-content:space-between;align-items:center;margin-bottom:16px;">
          <h2 style="display:inline-flex;align-items:center;gap:8px;">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <rect x="2" y="3" width="20" height="14" rx="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/>
            </svg>
            파트너 정산 목록
            <span id="tableCountBadge" style="font-size:13px;font-weight:600;color:var(--muted);"></span>
          </h2>
        </div>
        <div class="table-responsive">
          <table>
            <thead>
              <tr>
                <th>파트너 / ID</th>
                <th>정산월</th>
                <th>숙소 수</th>
                <th>총 결제액 (GMV)</th>
                <th>수수료</th>
                <th>쿠폰 파트너 부담</th>
                <th>최종 지급액 (Net)</th>
                <th>정산 상태</th>
                <th style="text-align:right;">관리</th>
              </tr>
            </thead>
            <tbody id="settlementTbody">
              <tr class="no-result"><td colspan="9">검색 조건을 설정한 후 <strong>[검색]</strong> 버튼을 눌러주세요.</td></tr>
            </tbody>
          </table>
        </div>
        <!-- 페이징 -->
        <div id="pagination" style="display:flex;justify-content:center;gap:6px;padding:16px 0;"></div>
      </div>

    </main>
  </div>
</div>

<div class="toast" id="toast"></div>

<script src="${pageContext.request.contextPath}/dist/js/admin/settlement.js"></script>
</body>
</html>
