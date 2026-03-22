<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>TripanSuper — 포인트 관리</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/admin.css">
  <style>
    /* ── 포인트 관리 전용 스타일 ── */
    .pt-main-grid {
      display: grid;
      grid-template-columns: 1fr 380px;
      gap: 20px;
      align-items: start;
    }
    @media (max-width: 1200px) { .pt-main-grid { grid-template-columns: 1fr; } }

    /* 체크박스 컬럼 */
    .col-check  { width: 36px; text-align: center; }
    .col-rank   { width: 36px; text-align: center; }
    .col-member { width: 160px; }
    .col-rem    { width: 110px; text-align: right; }
    .col-earned { width: 100px; text-align: right; }
    .col-used   { width: 100px; text-align: right; }
    .col-date   { width: 100px; }
    .col-act    { width: 70px; text-align: right; }

    /* 내역 버튼 한 줄 */
    .col-act .btn { white-space: nowrap; }

    /* 선택된 행 */
    tbody tr.pt-selected td { background: rgba(59,110,248,.06); }

    /* 일괄 액션 바 */
    .pt-bulk-bar {
      display: none; align-items: center; gap: 12px;
      padding: 12px 20px; background: #EFF6FF;
      border: 1.5px solid #BFDBFE; border-radius: var(--radius-md);
      margin-bottom: 16px; animation: fadeUp .2s ease;
    }
    .pt-bulk-bar.visible { display: flex; }
    .pt-bulk-count {
      font-size: 13px; font-weight: 800; color: #1D4ED8;
      background: #DBEAFE; padding: 4px 12px; border-radius: 20px;
    }
    .pt-bulk-label { font-size: 13px; font-weight: 700; color: var(--text); }

    /* 우측 패널 */
    .pt-panel-header { padding: 18px 24px; border-bottom: 1px solid var(--border); }
    .pt-panel-name   { font-size: 15px; font-weight: 800; color: var(--text); }
    .pt-panel-meta   { font-size: 12px; color: var(--muted); margin-top: 3px; }
    .pt-panel-balance {
      display: flex; align-items: baseline; gap: 6px; margin-top: 10px;
    }
    .pt-balance-label { font-size: 12px; color: var(--muted); font-weight: 600; }
    .pt-balance-value {
      font-family: var(--font-display); font-size: 26px; font-weight: 800;
      color: var(--primary);
    }
    .pt-balance-unit  { font-size: 13px; color: var(--muted); }

    /* 내역 필터 */
    .pt-hist-filter {
      display: flex; gap: 6px; padding: 10px 20px;
      border-bottom: 1px solid var(--border); align-items: center;
    }
    .pt-hist-filter input[type="date"] {
      height: 30px; font-size: 12px; padding: 0 8px;
      border: 1px solid var(--border); border-radius: var(--radius-md);
      background: var(--bg); color: var(--text); outline: none;
    }
    .pt-hist-filter input[type="date"]:focus { border-color: var(--primary); }
    .pt-hist-sep { font-size: 11px; color: var(--muted); }

    /* 포인트 내역 리스트 */
    .pt-hist-list {
      overflow-y: auto; max-height: 500px;
    }
    .pt-hist-item {
      display: flex; align-items: center; gap: 12px;
      padding: 12px 20px; border-bottom: 1px dashed var(--border);
      transition: .1s;
    }
    .pt-hist-item:last-child { border-bottom: none; }
    .pt-hist-item:hover { background: rgba(59,110,248,.03); }

    .pt-hist-icon {
      width: 32px; height: 32px; border-radius: 50%;
      display: flex; align-items: center; justify-content: center;
      font-size: 14px; flex-shrink: 0;
    }
    .pt-hist-icon.plus  { background: #ECFDF5; color: var(--success); }
    .pt-hist-icon.minus { background: #FEF2F2; color: var(--danger);  }

    .pt-hist-info { flex: 1; min-width: 0; }
    .pt-hist-reason { font-size: 13px; font-weight: 700; color: var(--text); }
    .pt-hist-date   { font-size: 11px; color: var(--muted); margin-top: 2px; }
    .pt-hist-order  { font-size: 11px; color: var(--muted); }

    .pt-hist-amount {
      font-family: var(--font-display); font-size: 14px; font-weight: 800;
      flex-shrink: 0; text-align: right;
    }
    .pt-hist-amount.plus  { color: var(--success); }
    .pt-hist-amount.minus { color: var(--danger);  }
    .pt-hist-rem {
      font-size: 11px; color: var(--muted); text-align: right; margin-top: 2px;
    }

    /* 빈 패널 */
    .pt-empty { padding: 50px 24px; text-align: center; color: var(--muted); }
    .pt-empty-text { font-size: 13px; line-height: 1.7; margin-top: 12px; }

    /* 모달 */
    .pt-modal-overlay {
      position: fixed; inset: 0;
      background: rgba(15,23,42,.55);
      backdrop-filter: blur(6px); -webkit-backdrop-filter: blur(6px);
      display: none; justify-content: center; align-items: center;
      z-index: 3000; padding: 24px;
    }
    .pt-modal-overlay.open { display: flex; }
    .pt-modal-sheet {
      background: var(--surface); width: 100%; max-width: 440px;
      border-radius: var(--radius-xl); overflow: hidden;
      box-shadow: var(--shadow-lg);
      animation: ptModalUp .25s cubic-bezier(.16,1,.3,1);
      display: flex; flex-direction: column;
    }
    @keyframes ptModalUp {
      from { opacity:0; transform:translateY(14px) scale(.98); }
      to   { opacity:1; transform:translateY(0)    scale(1); }
    }
    .pt-ms-head    { padding: 24px 28px 16px; border-bottom: 1px solid var(--border); }
    .pt-ms-head h3 { font-size: 17px; font-weight: 900; margin: 0 0 4px; color: var(--text); }
    .pt-ms-head p  { font-size: 13px; color: var(--muted); margin: 0; }
    .pt-ms-body    { padding: 22px 28px; display: flex; flex-direction: column; gap: 16px; }
    .pt-ms-foot    { padding: 16px 28px; border-top: 1px solid var(--border); display: flex; gap: 10px; }
    .pt-ms-foot .btn-m {
      flex: 1; height: 46px; border-radius: var(--radius-md);
      font-weight: 700; font-size: 14px; border: none;
      cursor: pointer; transition: opacity .15s; font-family: inherit;
    }
    .pt-ms-foot .btn-m-ghost   { background: var(--bg); color: var(--text); border: 1px solid var(--border); }
    .pt-ms-foot .btn-m-primary { background: var(--text); color: #fff; }
    .pt-ms-foot .btn-m:hover   { opacity: .84; }

    .pt-fg { display: flex; flex-direction: column; gap: 7px; }
    .pt-fg label {
      font-size: 11px; font-weight: 800; color: var(--muted);
      text-transform: uppercase; letter-spacing: .05em;
    }
    .pt-fg input, .pt-fg select, .pt-fg textarea {
      width: 100%; border: 1.5px solid var(--border); border-radius: var(--radius-md);
      padding: 10px 14px; font-size: 14px; font-weight: 600;
      background: var(--bg); outline: none; transition: border-color .2s;
      box-sizing: border-box; font-family: inherit; color: var(--text);
    }
    .pt-fg input:focus, .pt-fg select:focus, .pt-fg textarea:focus {
      border-color: var(--primary); box-shadow: 0 0 0 3px var(--primary-10);
      background: var(--surface);
    }
    .pt-fg textarea { resize: vertical; min-height: 80px; line-height: 1.5; }

    /* 모달 닫기 버튼 */
    .pt-modal-close-btn {
      width: 28px; height: 28px; border-radius: 50%; border: none;
      background: var(--bg); color: var(--muted); font-size: 14px;
      cursor: pointer; display: flex; align-items: center; justify-content: center;
    }
    .pt-modal-close-btn:hover { background: var(--border); }
    .pt-type-row { display: flex; gap: 8px; }
    .pt-type-btn {
      flex: 1; height: 40px; border-radius: var(--radius-md);
      font-size: 13px; font-weight: 700; cursor: pointer;
      border: 1.5px solid var(--border); background: var(--bg);
      color: var(--muted); transition: .15s;
    }
    .pt-type-btn.active-give   { background: #ECFDF5; color: var(--success); border-color: var(--success); }
    .pt-type-btn.active-deduct { background: #FEF2F2; color: var(--danger);  border-color: var(--danger);  }

    /* 선택 회원 태그 */
    .pt-target-tags {
      display: flex; flex-wrap: wrap; gap: 6px; margin-bottom: 4px;
    }
    .pt-target-tag {
      background: var(--primary-10); color: var(--primary);
      font-size: 12px; font-weight: 700; padding: 3px 10px;
      border-radius: 20px;
    }
  </style>
</head>
<body>

<div class="admin-layout">
  <jsp:include page="../layout/sidebar.jsp">
    <jsp:param name="activePage" value="point"/>
  </jsp:include>

  <div class="main-wrapper">
    <jsp:include page="../layout/header.jsp" />

    <main class="main-content">

      <!-- ── 페이지 헤더 ── -->
      <div class="page-header fade-up">
        <div>
          <h1>포인트 관리</h1>
          <p>회원별 포인트 잔액 및 내역을 조회하고 지급·차감할 수 있습니다.</p>
        </div>
      </div>

      <!-- ── KPI ── -->
      <div class="kpi-grid" style="grid-template-columns:repeat(3,1fr);">
        <div class="card kpi-card fade-up fade-up-1">
          <div class="kpi-label">포인트 보유 회원</div>
          <div class="kpi-value" id="kpiHolders">-</div>
          <div class="kpi-sub">잔액 1P 이상</div>
        </div>
        <div class="card kpi-card fade-up fade-up-2">
          <div class="kpi-label">총 유통 포인트</div>
          <div class="kpi-value" id="kpiTotal" style="color:var(--primary);">-</div>
          <div class="kpi-sub">전체 회원 잔액 합산</div>
        </div>
        <div class="card kpi-card fade-up fade-up-3">
          <div class="kpi-label">오늘 지급 포인트</div>
          <div class="kpi-value" id="kpiToday" style="color:var(--success);">-</div>
          <div class="kpi-sub">관리자 지급 기준</div>
        </div>
      </div>

      <!-- ── 필터 카드 ── -->
      <div class="card filter-card fade-up">
        <div class="filter-row">
          <div class="filter-label">회원 검색</div>
          <input type="text" id="searchKeyword" class="keyword-input"
                 placeholder="닉네임 또는 아이디 검색..."
                 onkeyup="if(event.key==='Enter') ptLoadList()"
                 style="max-width:280px;">
          <div class="filter-actions">
            <button class="btn btn-ghost btn-sm" onclick="ptReset()">
              <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="1 4 1 10 7 10"/><path d="M3.51 15a9 9 0 1 0 .49-3.51"/></svg>
              초기화
            </button>
            <button class="btn btn-primary btn-sm" onclick="ptLoadList()">
              <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
              검색
            </button>
          </div>
        </div>
      </div>

      <!-- ── 일괄 액션 바 ── -->
      <div class="pt-bulk-bar" id="ptBulkBar">
        <span class="pt-bulk-count" id="ptBulkCount">0명</span>
        <span class="pt-bulk-label">선택됨</span>
        <div style="margin-left:auto;display:flex;gap:8px;">
          <button class="btn btn-sm" style="background:#ECFDF5;color:var(--success);"
                  onclick="ptOpenModal('give', true)">일괄 지급</button>
          <button class="btn btn-sm" style="background:#FEF2F2;color:var(--danger);"
                  onclick="ptOpenModal('deduct', true)">일괄 차감</button>
          <button class="btn btn-ghost btn-sm" onclick="ptClearCheck()">선택 해제</button>
        </div>
      </div>

      <!-- ── 메인: 회원 목록 풀폭 ── -->
      <div class="fade-up">

        <!-- 회원 목록 -->
        <div class="card table-card">
          <div class="w-header">
            <h2 style="display:inline-flex;align-items:center;gap:8px;">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
              회원 포인트 현황
            </h2>
            <span id="ptTotalCount" style="font-size:12px;color:var(--muted);font-weight:700;">총 0명</span>
          </div>
          <div class="table-responsive">
            <table>
              <thead>
                <tr>
                  <th class="col-check">
                    <input type="checkbox" id="checkAll" onchange="ptCheckAll(this)" />
                  </th>
                  <th class="col-rank">#</th>
                  <th class="col-member">회원</th>
                  <th class="col-rem right">잔여 포인트</th>
                  <th class="col-earned right">누적 적립</th>
                  <th class="col-used right">누적 사용</th>
                  <th class="col-date">마지막 변동</th>
                  <th class="col-act right">관리</th>
                </tr>
              </thead>
              <tbody id="ptTableBody">
                <tr><td colspan="8" style="text-align:center;padding:40px;color:var(--muted);">불러오는 중...</td></tr>
              </tbody>
            </table>
          </div>
          <div class="pagination" id="ptPagination"></div>
        </div>

      </div>

    </main>
  </div>
</div>


<!-- ══════════════════════════════════════
     포인트 내역 모달
══════════════════════════════════════ -->
<div class="pt-modal-overlay" id="ptHistModal">
  <div class="pt-modal-sheet" style="max-width:560px;">
    <div class="pt-ms-head" style="display:flex;align-items:flex-start;justify-content:space-between;">
      <div>
        <h3 id="ptHistModalName">-</h3>
        <p id="ptHistModalMeta">-</p>
        <div style="display:flex;align-items:baseline;gap:6px;margin-top:8px;">
          <span style="font-size:12px;color:var(--muted);font-weight:600;">잔여</span>
          <span class="pt-balance-value" id="ptHistModalBalance" style="font-size:22px;">0</span>
          <span style="font-size:13px;color:var(--muted);">P</span>
        </div>
      </div>
      <div style="display:flex;flex-direction:column;gap:6px;align-items:flex-end;">
        <button class="pt-modal-close-btn" onclick="document.getElementById('ptHistModal').classList.remove('open')">✕</button>
        <div style="display:flex;gap:6px;margin-top:4px;">
          <button class="btn btn-sm" style="background:#ECFDF5;color:var(--success);"
                  onclick="ptOpenModal('give', false)">지급</button>
          <button class="btn btn-sm" style="background:#FEF2F2;color:var(--danger);"
                  onclick="ptOpenModal('deduct', false)">차감</button>
        </div>
      </div>
    </div>
    <div class="pt-hist-filter">
      <input type="date" id="histStart" onchange="ptLoadHistory()" />
      <span class="pt-hist-sep">~</span>
      <input type="date" id="histEnd" onchange="ptLoadHistory()" />
      <button class="btn btn-ghost btn-sm" style="height:30px;font-size:12px;margin-left:auto;"
              onclick="ptClearHistFilter()">전체</button>
      <span id="ptHistCount" style="font-size:11px;color:var(--muted);"></span>
    </div>
    <div class="pt-hist-list" id="ptHistList" style="max-height:460px;"></div>
    <div class="pt-ms-foot">
      <button class="btn-m btn-m-ghost" onclick="document.getElementById('ptHistModal').classList.remove('open')">닫기</button>
    </div>
  </div>
</div>

<!-- ══════════════════════════════════════
     포인트 지급/차감 모달
══════════════════════════════════════ -->
<div class="pt-modal-overlay" id="ptAdjustModal">
  <div class="pt-modal-sheet">

    <div class="pt-ms-head">
      <h3 id="ptModalTitle">포인트 지급</h3>
      <p id="ptModalDesc">선택된 회원에게 포인트를 지급합니다.</p>
    </div>

    <div class="pt-ms-body">
      <!-- 대상 회원 태그 -->
      <div class="pt-fg">
        <label>대상 회원</label>
        <div class="pt-target-tags" id="ptTargetTags"></div>
      </div>

      <!-- 지급/차감 토글 -->
      <div class="pt-fg">
        <label>유형</label>
        <div class="pt-type-row">
          <button class="pt-type-btn" id="ptTypeBtnGive"   onclick="ptSetType('give')">지급 (+)</button>
          <button class="pt-type-btn" id="ptTypeBtnDeduct" onclick="ptSetType('deduct')">차감 (−)</button>
        </div>
      </div>

      <!-- 포인트 금액 -->
      <div class="pt-fg">
        <label>포인트 <span style="color:var(--danger);">*</span></label>
        <input type="number" id="ptAdjustAmount" min="1" placeholder="예: 1000" />
      </div>

      <!-- 사유 -->
      <div class="pt-fg">
        <label>지급 사유 <span style="color:var(--danger);">*</span></label>
        <textarea id="ptAdjustReason" placeholder="예: 이벤트 참여 보상, 고객 보상 등"></textarea>
      </div>
    </div>

    <div class="pt-ms-foot">
      <button class="btn-m btn-m-ghost" onclick="ptCloseModal()">취소</button>
      <button class="btn-m btn-m-primary" onclick="ptSubmitAdjust()">확인</button>
    </div>
  </div>
</div>


<!-- ══════════════════════════════════════
     JavaScript
══════════════════════════════════════ -->
<script>
(function () {
  var CTX         = '${pageContext.request.contextPath}';
  var allMembers  = [];
  var filtered    = [];
  var page        = 1;
  var PAGE_SIZE   = 15;
  var selectedId  = null;     // 우측 패널 선택된 memberId
  var checkedIds  = new Set(); // 체크박스 선택 목록
  var modalType   = 'give';   // 'give' | 'deduct'
  var isBulk      = false;

  /* ── 초기화 ── */
  function init() {
    ptLoadList();
    ptLoadKpi();
  }

  /* ── KPI ── */
  function ptLoadKpi() {
    fetch(CTX + '/admin/api/point/members')
      .then(function (r) { return r.json(); })
      .then(function (list) {
        var holders = (list || []).filter(function (m) { return m.remPoint > 0; }).length;
        var total   = (list || []).reduce(function (s, m) { return s + (m.remPoint || 0); }, 0);
        document.getElementById('kpiHolders').textContent = holders.toLocaleString() + '명';
        document.getElementById('kpiTotal').textContent   = total.toLocaleString() + 'P';
      }).catch(function () {});

    /* 오늘 지급 포인트는 별도 API 없으면 '-' */
    document.getElementById('kpiToday').textContent = '-';
  }

  /* ── 목록 로드 ── */
  window.ptLoadList = function () {
    var keyword = document.getElementById('searchKeyword').value.trim();
    var url     = CTX + '/admin/api/point/members';
    if (keyword) url += '?keyword=' + encodeURIComponent(keyword);

    fetch(url)
      .then(function (r) { return r.json(); })
      .then(function (data) {
        allMembers = data || [];
        filtered   = allMembers;
        page       = 1;
        renderTable();
      })
      .catch(function () {
        document.getElementById('ptTableBody').innerHTML =
          '<tr><td colspan="8" style="text-align:center;padding:40px;color:var(--danger);">불러오지 못했습니다.</td></tr>';
      });
  };

  window.ptReset = function () {
    document.getElementById('searchKeyword').value = '';
    ptLoadList();
  };

  /* ── 테이블 렌더링 ── */
  function renderTable() {
    var tbody = document.getElementById('ptTableBody');
    var total = filtered.length;
    document.getElementById('ptTotalCount').textContent = '총 ' + total + '명';

    if (total === 0) {
      tbody.innerHTML = '<tr><td colspan="8" style="text-align:center;padding:40px;color:var(--muted);">회원이 없습니다.</td></tr>';
      document.getElementById('ptPagination').innerHTML = '';
      return;
    }

    var start = (page - 1) * PAGE_SIZE;
    var paged = filtered.slice(start, start + PAGE_SIZE);

    tbody.innerHTML = paged.map(function (m, i) {
      var rank    = start + i + 1;
      var checked = checkedIds.has(m.memberId) ? ' checked' : '';
      var sel     = m.memberId === selectedId ? ' pt-selected' : '';

      return '<tr class="' + sel + '" onclick="ptSelectMember(' + m.memberId + ')" style="cursor:pointer;">' +
        '<td class="col-check" onclick="event.stopPropagation();">' +
          '<input type="checkbox" class="row-check"' + checked +
          ' value="' + m.memberId + '" onchange="ptOnCheck(this)" /></td>' +
        '<td class="col-rank" style="color:var(--muted);font-size:12px;">' + rank + '</td>' +
        '<td class="col-member">' +
          '<div style="font-weight:700;font-size:13px;">' + escHtml(m.nickname || '-') + '</div>' +
          '<div style="font-size:11px;color:var(--muted);">' + escHtml(m.loginId || '') + '</div>' +
        '</td>' +
        '<td class="col-rem right num" style="font-weight:800;color:var(--primary);">' +
          (m.remPoint || 0).toLocaleString() + 'P</td>' +
        '<td class="col-earned right num" style="color:var(--success);">+' +
          (m.totalEarned || 0).toLocaleString() + '</td>' +
        '<td class="col-used right num" style="color:var(--danger);">-' +
          (m.totalUsed || 0).toLocaleString() + '</td>' +
        '<td class="col-date" style="font-size:12px;color:var(--muted);">' +
          (m.lastChangeDate || '-') + '</td>' +
        '<td class="col-act right">' +
          '<button class="btn btn-ghost btn-sm" style="white-space:nowrap;" ' +
          'onclick="event.stopPropagation();ptSelectMember(' + m.memberId + ')">내역</button>' +
        '</td>' +
      '</tr>';
    }).join('');

    renderPagination(total);
  }

  /* ── 페이지네이션 ── */
  function renderPagination(total) {
    var totalPages = Math.ceil(total / PAGE_SIZE);
    var area       = document.getElementById('ptPagination');
    if (totalPages <= 1) { area.innerHTML = ''; return; }
    var html = '';
    for (var i = 1; i <= totalPages; i++) {
      html += '<button class="pg-btn' + (i === page ? ' active' : '') +
              '" onclick="ptGoPage(' + i + ')">' + i + '</button>';
    }
    area.innerHTML = html;
  }
  window.ptGoPage = function (p) { page = p; renderTable(); };

  /* ── 체크박스 ── */
  window.ptCheckAll = function (cb) {
    var start = (page - 1) * PAGE_SIZE;
    var paged = filtered.slice(start, start + PAGE_SIZE);
    paged.forEach(function (m) {
      if (cb.checked) checkedIds.add(m.memberId);
      else            checkedIds.delete(m.memberId);
    });
    renderTable();
    updateBulkBar();
  };

  window.ptOnCheck = function (cb) {
    var id = Number(cb.value);
    if (cb.checked) checkedIds.add(id);
    else            checkedIds.delete(id);
    updateBulkBar();
  };

  function updateBulkBar() {
    var bar   = document.getElementById('ptBulkBar');
    var count = checkedIds.size;
    if (count > 0) {
      bar.classList.add('visible');
      document.getElementById('ptBulkCount').textContent = count + '명';
    } else {
      bar.classList.remove('visible');
    }
  }

  window.ptClearCheck = function () {
    checkedIds.clear();
    document.getElementById('checkAll').checked = false;
    renderTable();
    updateBulkBar();
  };

  /* ── 회원 선택 / 내역 모달 ── */
  window.ptSelectMember = function (memberId) {
    selectedId = memberId;
    renderTable();

    var m = allMembers.find(function (x) { return x.memberId === memberId; });
    if (!m) return;

    document.getElementById('ptHistModalName').textContent    = m.nickname || '-';
    document.getElementById('ptHistModalMeta').textContent    = m.loginId  || '';
    document.getElementById('ptHistModalBalance').textContent = (m.remPoint || 0).toLocaleString();

    document.getElementById('ptHistModal').classList.add('open');
    ptLoadHistory();
  };

  /* ── 포인트 내역 로드 ── */
  function ptLoadHistory() {
    if (!selectedId) return;
    var start  = document.getElementById('histStart').value;
    var end    = document.getElementById('histEnd').value;
    var list   = document.getElementById('ptHistList');
    var countEl = document.getElementById('ptHistCount');
    list.innerHTML = '<div class="pt-empty"><div class="pt-empty-text">불러오는 중...</div></div>';

    var url = CTX + '/admin/api/point/members/' + selectedId + '/history';
    var params = [];
    if (start) params.push('startDate=' + start);
    if (end)   params.push('endDate='   + end);
    if (params.length) url += '?' + params.join('&');

    fetch(url)
      .then(function (r) { return r.json(); })
      .then(function (data) {
        if (!data || data.length === 0) {
          list.innerHTML = '<div class="pt-empty"><div class="pt-empty-text">포인트 내역이 없습니다.</div></div>';
          if (countEl) countEl.textContent = '';
          return;
        }
        if (countEl) countEl.textContent = '총 ' + data.length + '건';

        list.innerHTML = data.map(function (h) {
          var isPlus = h.pointAmount > 0;
          var sign   = isPlus ? '+' : '';
          return '<div class="pt-hist-item">' +
            '<div class="pt-hist-icon ' + (isPlus ? 'plus' : 'minus') + '">' +
              (isPlus ? '▲' : '▼') +
            '</div>' +
            '<div class="pt-hist-info">' +
              '<div class="pt-hist-reason">' + escHtml(h.changeReason || '-') + '</div>' +
              '<div class="pt-hist-date">'   + escHtml(h.regDate      || '') + '</div>' +
              (h.orderId ? '<div class="pt-hist-order">주문 #' + escHtml(h.orderId) + '</div>' : '') +
            '</div>' +
            '<div>' +
              '<div class="pt-hist-amount ' + (isPlus ? 'plus' : 'minus') + '">' +
                sign + h.pointAmount.toLocaleString() + 'P' +
              '</div>' +
              '<div class="pt-hist-rem">잔여 ' + (h.remPoint || 0).toLocaleString() + 'P</div>' +
            '</div>' +
          '</div>';
        }).join('');
      })
      .catch(function () {
        list.innerHTML = '<div class="pt-empty"><div class="pt-empty-text" style="color:var(--danger);">불러오지 못했습니다.</div></div>';
      });
  }
  window.ptLoadHistory = ptLoadHistory;

  window.ptClearHistFilter = function () {
    document.getElementById('histStart').value = '';
    document.getElementById('histEnd').value   = '';
    ptLoadHistory();
  };

  /* ── 모달 ── */
  window.ptOpenModal = function (type, bulk) {
    modalType = type;
    isBulk    = bulk;

    /* 대상 태그 렌더링 */
    var targets = bulk
      ? Array.from(checkedIds).map(function (id) {
          var m = allMembers.find(function (x) { return x.memberId === id; });
          return m ? m.nickname : id;
        })
      : (selectedId
          ? [allMembers.find(function (x) { return x.memberId === selectedId; })]
               .filter(Boolean).map(function (m) { return m.nickname; })
          : []);

    document.getElementById('ptTargetTags').innerHTML =
      targets.map(function (n) {
        return '<span class="pt-target-tag">' + escHtml(String(n)) + '</span>';
      }).join('');

    document.getElementById('ptModalTitle').textContent =
      (type === 'give' ? '포인트 지급' : '포인트 차감') +
      (bulk ? ' (일괄)' : '');
    document.getElementById('ptModalDesc').textContent =
      type === 'give'
        ? '선택된 회원에게 포인트를 지급합니다.'
        : '선택된 회원의 포인트를 차감합니다.';

    document.getElementById('ptAdjustAmount').value = '';
    document.getElementById('ptAdjustReason').value = '';

    ptSetType(type);
    document.getElementById('ptAdjustModal').classList.add('open');
  };

  window.ptCloseModal = function () {
    document.getElementById('ptAdjustModal').classList.remove('open');
  };

  window.ptSetType = function (type) {
    modalType = type;
    var btnGive   = document.getElementById('ptTypeBtnGive');
    var btnDeduct = document.getElementById('ptTypeBtnDeduct');
    btnGive.className   = 'pt-type-btn' + (type === 'give'   ? ' active-give'   : '');
    btnDeduct.className = 'pt-type-btn' + (type === 'deduct' ? ' active-deduct' : '');
  };

  document.getElementById('ptAdjustModal').addEventListener('click', function (e) {
    if (e.target === this) ptCloseModal();
  });

  /* ── 포인트 지급/차감 제출 ── */
  window.ptSubmitAdjust = function () {
    var amount = parseInt(document.getElementById('ptAdjustAmount').value, 10);
    var reason = document.getElementById('ptAdjustReason').value.trim();

    if (!amount || amount <= 0) { alert('포인트를 올바르게 입력해주세요.'); return; }
    if (!reason)                { alert('지급 사유를 입력해주세요.'); return; }

    var ids = isBulk
      ? Array.from(checkedIds)
      : (selectedId ? [selectedId] : []);

    if (ids.length === 0) { alert('대상 회원을 선택해주세요.'); return; }

    var finalAmount = modalType === 'give' ? amount : -amount;

    fetch(CTX + '/admin/api/point/adjust', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        memberIds:    ids,
        pointAmount:  finalAmount,
        changeReason: reason
      })
    })
    .then(function (r) {
      if (!r.ok) return r.json().then(function (d) { throw new Error(d.message); });
    })
    .then(function () {
      ptCloseModal();
      ptLoadList();
      ptLoadKpi();
      if (selectedId) ptLoadHistory();
      alert((modalType === 'give' ? '지급' : '차감') + ' 완료되었습니다.');
    })
    .catch(function (e) { alert(e.message || '처리에 실패했습니다.'); });
  };

  /* ── XSS 방지 ── */
  function escHtml(str) {
    return String(str)
      .replace(/&/g, '&amp;').replace(/</g, '&lt;')
      .replace(/>/g, '&gt;').replace(/"/g, '&quot;');
  }

  init();
})();
</script>
</body>
</html>
