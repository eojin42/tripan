<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>TripanSuper — 휴면 회원 관리</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/admin.css">
  <style>
    /* ── 아이콘 공통 ── */
    .section-icon { display: inline-flex; align-items: center; gap: 8px; }
    .section-icon svg { width: 18px; height: 18px; stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; flex-shrink: 0; }

    /* ── 체크박스 ── */
    .col-check { width: 44px; text-align: center; }
    input[type="checkbox"] { width: 16px; height: 16px; cursor: pointer; accent-color: var(--primary); }

    /* ── 일괄 액션 바 ── */
    .bulk-bar {
      display: none; align-items: center; gap: 12px;
      padding: 12px 20px; background: #EFF6FF;
      border: 1.5px solid #BFDBFE; border-radius: 14px;
      margin-bottom: 16px; animation: slideDown 0.2s ease;
    }
    .bulk-bar.visible { display: flex; }
    @keyframes slideDown { from { opacity:0; transform:translateY(-6px); } to { opacity:1; transform:translateY(0); } }
    .bulk-count { font-size: 13px; font-weight: 800; color: #1D4ED8; background: #DBEAFE; padding: 4px 12px; border-radius: 20px; }
    .bulk-bar-label { font-size: 13px; font-weight: 700; color: var(--text); }
    .bulk-bar-actions { display: flex; gap: 8px; margin-left: auto; }
    .btn-bulk { height: 36px; padding: 0 16px; border-radius: 9px; font-size: 13px; font-weight: 800; border: none; cursor: pointer; transition: opacity 0.15s; white-space: nowrap; }
    .btn-bulk-mail   { background: #EFF6FF; color: #1D4ED8; border: 1px solid #BFDBFE; }
    .btn-bulk-delete { background: #FFF1F2; color: var(--danger); border: 1px solid #FECDD3; }
    .btn-bulk-excel  { background: var(--bg); color: var(--text); border: 1px solid var(--border); }
    .btn-bulk:hover  { opacity: 0.8; }

    /* ── 파기 예정일 D-Day 뱃지 ── */
    .dday-badge {
      display: inline-flex; align-items: center; gap: 5px;
      font-size: 12px; font-weight: 800;
      padding: 3px 10px; border-radius: 20px;
    }
    .dday-urgent  { background: #FFF1F2; color: var(--danger); }
    .dday-warning { background: #FFF7ED; color: #C2410C; }
    .dday-normal  { background: var(--bg); color: var(--muted); }

    /* ── 모달 기반 ── */
    .modal-overlay {
      position: fixed; inset: 0; background: rgba(15,23,42,0.5);
      backdrop-filter: blur(6px); display: none;
      justify-content: center; align-items: center;
      z-index: 3000; padding: 24px;
    }
    .modal-sheet {
      background: #fff; width: 100%; max-width: 460px;
      border-radius: 22px; overflow: hidden;
      box-shadow: 0 24px 64px rgba(0,0,0,0.16);
      animation: modalUp 0.3s cubic-bezier(0.16,1,0.3,1);
      display: flex; flex-direction: column;
    }
    @keyframes modalUp { from{opacity:0;transform:translateY(20px)} to{opacity:1;transform:translateY(0)} }

    .ms-head         { padding: 26px 28px 18px; border-bottom: 1px solid var(--border); }
    .ms-head h3      { font-size: 17px; font-weight: 900; margin: 0 0 4px; }
    .ms-head p       { font-size: 13px; color: var(--muted); margin: 0; }
    .ms-head.warn    { background: linear-gradient(135deg, #FFF1F1 0%, #FFE8E8 100%); border-bottom-color: #FFD0D0; }
    .ms-head.warn h3 { color: var(--danger); }
    .ms-head.warn p  { color: #e05050; opacity: 0.85; }
    .ms-warn-icon    { width: 40px; height: 40px; border-radius: 12px; background: var(--danger); display: flex; align-items: center; justify-content: center; margin-bottom: 12px; }
    .ms-warn-icon svg { width: 20px; height: 20px; stroke: #fff; fill: none; stroke-width: 2.2; stroke-linecap: round; stroke-linejoin: round; }

    .ms-body { padding: 22px 28px; display: flex; flex-direction: column; gap: 14px; font-size: 14px; }
    .ms-info-row { display: flex; justify-content: space-between; padding: 10px 0; border-bottom: 1px solid var(--border); }
    .ms-info-row:last-child { border-bottom: none; }
    .ms-info-row dt { font-size: 12px; font-weight: 800; color: var(--muted); }
    .ms-info-row dd { font-size: 14px; font-weight: 700; color: var(--text); }

    .ms-foot { padding: 16px 28px; border-top: 1px solid var(--border); display: flex; gap: 10px; }
    .btn-m         { flex:1; height: 46px; border-radius: 11px; font-weight: 800; font-size: 14px; border: none; cursor: pointer; transition: opacity 0.15s; }
    .btn-m-ghost   { background: var(--bg); color: var(--text); }
    .btn-m-primary { background: #111; color: #fff; }
    .btn-m-danger  { background: var(--danger); color: #fff; }
    .btn-m:hover   { opacity: 0.84; }

    /* ── 테이블 액션 버튼 ── */
    .btn-row-mail   { height: 30px; padding: 0 12px; border-radius: 7px; font-size: 12px; font-weight: 700; border: 1px solid #BFDBFE; background: #EFF6FF; color: #1D4ED8; cursor: pointer; transition: all 0.15s; }
    .btn-row-mail:hover { background: #DBEAFE; }
    .btn-row-del    { height: 30px; padding: 0 12px; border-radius: 7px; font-size: 12px; font-weight: 700; border: 1px solid var(--danger); background: transparent; color: var(--danger); cursor: pointer; transition: all 0.15s; }
    .btn-row-del:hover  { background: var(--danger); color: #fff; }
    .btn-row-restore { height: 30px; padding: 0 12px; border-radius: 7px; font-size: 12px; font-weight: 700; border: 1px solid #BBF7D0; background: #F0FDF4; color: #15803D; cursor: pointer; transition: all 0.15s; }
    .btn-row-restore:hover { background: #DCFCE7; }

    .filter-row .btn { display: inline-flex; align-items: center; gap: 6px; }
  </style>
</head>
<body>

<div class="admin-layout">
  <jsp:include page="../layout/sidebar.jsp"><jsp:param name="activePage" value="dormant"/></jsp:include>

  <div class="main-wrapper">
    <jsp:include page="../layout/header.jsp" />

    <main class="main-content">

      <!-- 페이지 헤더 -->
      <div class="page-header fade-up">
        <div>
          <h1>휴면 회원 관리</h1>
          <p>1년 이상 장기 미접속으로 휴면 처리된 회원과 개인정보 파기 대상을 관리합니다.</p>
        </div>
        <div class="header-actions">
          <button class="btn btn-primary" onclick="openMassMailModal()"
                  style="display:inline-flex; align-items:center; gap:8px;">
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
              <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/>
              <polyline points="22,6 12,13 2,6"/>
            </svg>
            일괄 복귀 안내 메일 발송
          </button>
        </div>
      </div>

      <!-- KPI 카드 -->
      <div class="kpi-grid">
        <div class="card kpi-card fade-up fade-up-1">
          <div class="kpi-label">전체 휴면 회원</div>
          <div class="kpi-value" id="kpiTotalDormant">${not empty dormantKpi.totalDormant ? dormantKpi.totalDormant : 0}</div>
          <div class="kpi-sub">보안 DB 분리 보관 중</div>
        </div>
        <div class="card kpi-card fade-up fade-up-2">
          <div class="kpi-label">이번 달 파기 예정</div>
          <div class="kpi-value" style="color:var(--danger)" id="kpiWillDelete">${not empty dormantKpi.willDeleteCount ? dormantKpi.willDeleteCount : 0}</div>
          <div class="badge badge-danger">30일 내 영구 삭제 대상</div>
        </div>
        <div class="card kpi-card fade-up fade-up-3">
          <div class="kpi-label">최근 복귀 유저</div>
          <div class="kpi-value" style="color:var(--success)" id="kpiReactivated">${not empty dormantKpi.reactivatedCount ? dormantKpi.reactivatedCount : 0}</div>
          <div class="kpi-sub">지난 7일 기준</div>
        </div>
      </div>

      <!-- 검색 필터 -->
      <div class="card filter-card fade-up">
        <div class="filter-row">
          <div class="filter-label">휴면 회원 검색</div>

          <select class="filter-select" id="searchCategory" style="width:130px;">
            <option value="id">ID (이메일)</option>
            <option value="nickname">닉네임</option>
          </select>

          <input type="text" id="searchInput" class="keyword-input"
                 placeholder="검색어 입력 (공란: 전체 조회)"
                 onkeyup="if(event.key==='Enter') searchDormant()" style="flex:1;">

          <div style="display:flex; align-items:center; gap:8px;">
            <span style="font-size:12px; font-weight:800; color:var(--muted); white-space:nowrap;">파기 예정</span>
            <select class="filter-select" id="filterDeadline" style="width:140px;">
              <option value="ALL">전체</option>
              <option value="30">30일 이내</option>
              <option value="60">60일 이내</option>
              <option value="90">90일 이내</option>
            </select>
          </div>

          <button class="btn btn-primary" onclick="searchDormant()">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
            검색
          </button>
        </div>
      </div>

      <!-- 목록 테이블 -->
      <div class="card table-card fade-up">
        <div class="w-header" style="display:flex; justify-content:space-between; align-items:center; margin-bottom:16px;">
          <h2 class="section-icon">
            <svg viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
            휴면 회원 목록
          </h2>
          <div style="display:flex; gap:10px; align-items:center;">
            <span style="font-size:13px; color:var(--muted);" id="resultCount"></span>
            <button class="btn btn-outline btn-sm" onclick="downloadDormantExcel()" style="display:inline-flex; align-items:center; gap:6px;">
              <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
              엑셀 다운로드
            </button>
          </div>
        </div>

        <!-- 일괄 액션 바 -->
        <div class="bulk-bar" id="bulkBar">
          <span class="bulk-count" id="bulkCount">0명</span>
          <span class="bulk-bar-label">선택됨</span>
          <div class="bulk-bar-actions">
            <button class="btn-bulk btn-bulk-mail"   onclick="openBulkMailModal()">복귀 안내 메일</button>
            <button class="btn-bulk btn-bulk-delete" onclick="openBulkDeleteModal()">일괄 파기</button>
            <button class="btn-bulk btn-bulk-excel"  onclick="downloadDormantExcel(true)">선택 엑셀</button>
          </div>
        </div>

        <div class="table-responsive">
          <table>
            <thead>
              <tr>
                <th class="col-check">
                  <input type="checkbox" id="checkAll" onchange="toggleCheckAll(this)">
                </th>
                <th>ID / 이메일</th>
                <th>닉네임</th>
                <th>마지막 접속일</th>
                <th>휴면 전환일</th>
                <th>개인정보 파기 예정일</th>
                <th class="right">관리</th>
              </tr>
            </thead>
            <tbody id="dormantTableBody">
              <tr id="emptyDormantMsg">
                <td colspan="7" style="text-align:center; padding:50px 0; color:var(--muted);">
                  검색 조건을 설정한 후 <strong>[검색]</strong> 버튼을 눌러주세요.<br>
                  <small style="margin-top:6px; display:block;">(검색어 공란으로 검색 시 전체 휴면 회원이 조회됩니다)</small>
                </td>
              </tr>

              <c:forEach var="member" items="${dormantList}">
                <tr class="dormant-row"
                    style="display:none;"
                    data-email="${member.email}"
                    data-nickname="${member.nickname}"
                    data-lastlogin="<fmt:formatDate value='${member.lastLoginDate}' pattern='yyyy-MM-dd'/>"
                    data-dormantdate="<fmt:formatDate value='${member.dormantDate}' pattern='yyyy-MM-dd'/>"
                    data-deletedate="<fmt:formatDate value='${member.deleteScheduledDate}' pattern='yyyy-MM-dd'/>">

                  <td class="col-check">
                    <input type="checkbox" class="row-check"
                           value="${member.email}"
                           onchange="onRowCheck()" onclick="event.stopPropagation()">
                  </td>

                  <td class="col-id">
                    <strong style="color:var(--muted);">${member.email}</strong>
                  </td>

                  <td class="col-nickname">${member.nickname}</td>

                  <td class="num">
                    <fmt:formatDate value="${member.lastLoginDate}" pattern="yyyy-MM-dd"/>
                  </td>

                  <td class="num">
                    <fmt:formatDate value="${member.dormantDate}" pattern="yyyy-MM-dd"/>
                  </td>

                  <td class="num col-deletedate">
                    <%-- D-Day 계산은 JS에서 렌더링 --%>
                    <fmt:formatDate value="${member.deleteScheduledDate}" pattern="yyyy-MM-dd"/>
                  </td>

                  <td class="right" style="display:flex; gap:6px; justify-content:flex-end; flex-wrap:wrap;">
                    <button class="btn-row-restore" onclick="restoreMember(event, '${member.email}', this)">복귀 처리</button>
                    <button class="btn-row-mail"    onclick="sendEmail('${member.email}')">메일 발송</button>
                    <button class="btn-row-del"     onclick="openDeleteModal('${member.email}', '${member.nickname}')">즉시 파기</button>
                  </td>
                </tr>
              </c:forEach>
            </tbody>
          </table>
        </div>

        <!-- 페이지네이션 -->
        <div id="pagination-container" style="text-align:center; padding:16px 0;"></div>
      </div>

    </main>
  </div>
</div>

<!-- 모달 : 단건 즉시 파기 확인 -->
<div class="modal-overlay" id="deleteModal">
  <div class="modal-sheet">
    <div class="ms-head warn">
      <div class="ms-warn-icon">
        <svg viewBox="0 0 24 24"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14H6L5 6"/><path d="M10 11v6"/><path d="M14 11v6"/><path d="M9 6V4h6v2"/></svg>
      </div>
      <h3>개인정보 즉시 파기</h3>
      <p>이 작업은 되돌릴 수 없습니다.</p>
    </div>
    <div class="ms-body">
      <dl>
        <div class="ms-info-row"><dt>대상 회원</dt><dd id="deleteTargetDisplay">-</dd></div>
        <div class="ms-info-row" style="background:#FFF1F2; border-radius:10px; padding:12px; margin-top:4px; border:none;">
          <p style="font-size:13px; color:var(--danger); font-weight:700; margin:0; line-height:1.6;">
            계정 정보, 예약 이력, 개인 데이터가 모두 영구 삭제됩니다.<br>법적 보존 의무 데이터는 별도 보관됩니다.
          </p>
        </div>
      </dl>
    </div>
    <div class="ms-foot">
      <button class="btn-m btn-m-ghost"  onclick="closeDeleteModal()">취소</button>
      <button class="btn-m btn-m-danger" onclick="confirmDelete()">영구 파기</button>
    </div>
  </div>
</div>

<!-- 모달 : 일괄 파기 확인 -->
<div class="modal-overlay" id="bulkDeleteModal">
  <div class="modal-sheet">
    <div class="ms-head warn">
      <div class="ms-warn-icon">
        <svg viewBox="0 0 24 24"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14H6L5 6"/><path d="M10 11v6"/><path d="M14 11v6"/><path d="M9 6V4h6v2"/></svg>
      </div>
      <h3>개인정보 일괄 파기</h3>
      <p>이 작업은 되돌릴 수 없습니다.</p>
    </div>
    <div class="ms-body">
      <dl>
        <div class="ms-info-row"><dt>파기 대상</dt><dd id="bulkDeleteCount" style="color:var(--danger);">0명</dd></div>
        <div class="ms-info-row" style="background:#FFF1F2; border-radius:10px; padding:12px; margin-top:4px; border:none;">
          <p style="font-size:13px; color:var(--danger); font-weight:700; margin:0; line-height:1.6;">
            선택된 모든 회원의 계정 및 개인 데이터가 영구 삭제됩니다.
          </p>
        </div>
      </dl>
    </div>
    <div class="ms-foot">
      <button class="btn-m btn-m-ghost"  onclick="closeBulkDeleteModal()">취소</button>
      <button class="btn-m btn-m-danger" onclick="confirmBulkDelete()">일괄 영구 파기</button>
    </div>
  </div>
</div>

<!--  일괄 메일 발송 확인 -->
<div class="modal-overlay" id="bulkMailModal">
  <div class="modal-sheet">
    <div class="ms-head">
      <h3>복귀 안내 메일 일괄 발송</h3>
      <p id="bulkMailDesc">조회된 전체 휴면 회원에게 발송합니다.</p>
    </div>
    <div class="ms-body">
      <div class="ms-info-row"><dt>발송 대상</dt><dd id="bulkMailCount" style="color:var(--primary);">0명</dd></div>
      <p style="font-size:13px; color:var(--muted); line-height:1.6; margin:0;">
        휴면 해제 방법과 개인정보 파기 예정일 안내가 포함된 메일이 발송됩니다.
      </p>
    </div>
    <div class="ms-foot">
      <button class="btn-m btn-m-ghost"   onclick="closeBulkMailModal()">취소</button>
      <button class="btn-m btn-m-primary" onclick="confirmBulkMail()">발송 시작</button>
    </div>
  </div>
</div>

<script>
const contextPath = '${pageContext.request.contextPath}';

/* 전역 상태 */
let filteredRows  = [];
let currentPage   = 1;
const rowsPerPage = 10;
let hasSearched   = false;
let deleteTarget  = null; // 단건 파기 대상 이메일

/* 검색 & 필터 */
function searchDormant() {
  hasSearched = true;

  const category  = document.getElementById('searchCategory').value;
  const keyword   = document.getElementById('searchInput').value.toLowerCase().trim();
  const deadline  = document.getElementById('filterDeadline').value;
  const today     = new Date();
  today.setHours(0, 0, 0, 0);

  document.getElementById('emptyDormantMsg').style.display = 'none';
  document.getElementById('checkAll').checked = false;
  filteredRows = [];

  document.querySelectorAll('.dormant-row').forEach(row => {
    row.querySelector('.row-check').checked = false;

    let searchText = '';
    if (category === 'id') {
      searchText = (row.dataset.email    || '').toLowerCase();
    } else {
      searchText = (row.dataset.nickname || '').toLowerCase();
    }

    const matchKeyword = !keyword || searchText.includes(keyword);

    // 파기 예정일 필터
    let matchDeadline = true;
    if (deadline !== 'ALL') {
      const deleteDate = new Date(row.dataset.deletedate);
      const diffDays   = Math.ceil((deleteDate - today) / (1000 * 60 * 60 * 24));
      matchDeadline    = diffDays <= parseInt(deadline) && diffDays >= 0;
    }

    if (matchKeyword && matchDeadline) filteredRows.push(row);
    row.style.display = 'none';
  });

  currentPage = 1;
  renderTable();
  onRowCheck();
}

/* D-Day 배지 렌더링 */
function getDDayBadge(deleteDateStr) {
  const today      = new Date(); today.setHours(0,0,0,0);
  const deleteDate = new Date(deleteDateStr);
  const diffDays   = Math.ceil((deleteDate - today) / (1000 * 60 * 60 * 24));

  if (diffDays <= 0)  return `<span class="dday-badge dday-urgent">파기 대상</span>`;
  if (diffDays <= 30) return `<span class="dday-badge dday-urgent">D-${diffDays}</span> ${deleteDateStr}`;
  if (diffDays <= 60) return `<span class="dday-badge dday-warning">D-${diffDays}</span> ${deleteDateStr}`;
  return `<span class="dday-badge dday-normal">D-${diffDays}</span> ${deleteDateStr}`;
}

/* 페이징 렌더링 */
function renderTable() {
  document.querySelectorAll('.dormant-row').forEach(r => r.style.display = 'none');

  const tbody    = document.getElementById('dormantTableBody');
  const noResult = document.getElementById('noResultMsg');
  const countEl  = document.getElementById('resultCount');

  if (!hasSearched) return;

  if (filteredRows.length === 0) {
    if (!noResult) {
      tbody.insertAdjacentHTML('beforeend',
        '<tr id="noResultMsg"><td colspan="7" style="text-align:center;padding:30px;color:var(--danger);">일치하는 휴면 회원이 없습니다.</td></tr>');
    } else { noResult.style.display = ''; }
    if (countEl) countEl.textContent = '';
    renderPagination(0);
    return;
  }
  if (noResult) noResult.style.display = 'none';
  if (countEl)  countEl.textContent = '총 ' + filteredRows.length + '명';

  const start = (currentPage - 1) * rowsPerPage;
  for (let i = start; i < start + rowsPerPage && i < filteredRows.length; i++) {
    const row = filteredRows[i];
    // D-Day 배지 주입
    const ddCell = row.querySelector('.col-deletedate');
    if (ddCell) ddCell.innerHTML = getDDayBadge(row.dataset.deletedate);
    row.style.display = '';
  }
  renderPagination(filteredRows.length);
}

function renderPagination(totalRows) {
  const pc = document.getElementById('pagination-container');
  pc.innerHTML = '';
  if (totalRows === 0) return;
  const totalPages = Math.ceil(totalRows / rowsPerPage);
  for (let i = 1; i <= totalPages; i++) {
    const btn = document.createElement('button');
    btn.innerText = i;
    btn.className = i === currentPage ? 'btn btn-primary btn-sm' : 'btn btn-outline btn-sm';
    btn.style.margin = '0 3px';
    btn.onclick = () => { currentPage = i; renderTable(); };
    pc.appendChild(btn);
  }
}

/* 체크박스 */
function toggleCheckAll(master) {
  document.querySelectorAll('.dormant-row').forEach(row => {
    if (row.style.display !== 'none') row.querySelector('.row-check').checked = master.checked;
  });
  onRowCheck();
}

function onRowCheck() {
  let checked = 0, visible = 0;
  document.querySelectorAll('.dormant-row').forEach(row => {
    if (row.style.display !== 'none') {
      visible++;
      if (row.querySelector('.row-check').checked) checked++;
    }
  });
  const bar = document.getElementById('bulkBar');
  const cnt = document.getElementById('bulkCount');
  if (checked > 0) { bar.classList.add('visible'); cnt.textContent = checked + '명'; }
  else             { bar.classList.remove('visible'); }
  const ca = document.getElementById('checkAll');
  if (ca) { ca.checked = visible > 0 && checked === visible; ca.indeterminate = checked > 0 && checked < visible; }
}

/* 단건 복귀 처리*/
function restoreMember(event, email, btn) {
  event.stopPropagation();
  if (!confirm(email + ' 님을 휴면 해제하고 정상 활동 상태로 복귀시키겠습니까?')) return;

  // TODO: fetch POST /admin/member/restore { email }

  // UI 즉시 반영: 해당 행 목록에서 제거
  const row = btn.closest('.dormant-row');
  filteredRows = filteredRows.filter(r => r !== row);
  row.style.display = 'none';

  // KPI 감소
  const kpiEl = document.getElementById('kpiTotalDormant');
  if (kpiEl) kpiEl.textContent = Math.max(0, parseInt(kpiEl.textContent.replace(/,/g, '')) - 1);
  const reactEl = document.getElementById('kpiReactivated');
  if (reactEl) reactEl.textContent = parseInt(reactEl.textContent) + 1;

  renderPagination(filteredRows.length);
  document.getElementById('resultCount').textContent = '총 ' + filteredRows.length + '명';
  onRowCheck();
  alert('✅ ' + email + ' 님이 정상 활동 상태로 복귀되었습니다.');
}

/* 단건 파기 모달 */
function openDeleteModal(email, nickname) {
  deleteTarget = email;
  document.getElementById('deleteTargetDisplay').textContent = nickname + ' (' + email + ')';
  document.getElementById('deleteModal').style.display = 'flex';
}
function closeDeleteModal() { document.getElementById('deleteModal').style.display = 'none'; }

function confirmDelete() {
  if (!deleteTarget) return;

  // TODO: fetch DELETE /admin/member/dormant { email: deleteTarget }

  // UI 즉시 반영
  const row = [...document.querySelectorAll('.dormant-row')]
              .find(r => r.dataset.email === deleteTarget);
  if (row) {
    filteredRows = filteredRows.filter(r => r !== row);
    row.style.display = 'none';
  }
  const kpiEl = document.getElementById('kpiTotalDormant');
  if (kpiEl) kpiEl.textContent = Math.max(0, parseInt(kpiEl.textContent.replace(/,/g, '')) - 1);

  renderPagination(filteredRows.length);
  if (filteredRows.length === 0 && hasSearched) {
    const noResult = document.getElementById('noResultMsg');
    if (noResult) noResult.style.display = '';
  }
  document.getElementById('resultCount').textContent = '총 ' + filteredRows.length + '명';

  closeDeleteModal();
  alert('✅ 개인정보가 파기 처리되었습니다.');
  deleteTarget = null;
}

/* 일괄 파기 모달 */
function openBulkDeleteModal() {
  const cnt = document.getElementById('bulkCount').textContent;
  document.getElementById('bulkDeleteCount').textContent = cnt;
  document.getElementById('bulkDeleteModal').style.display = 'flex';
}
function closeBulkDeleteModal() { document.getElementById('bulkDeleteModal').style.display = 'none'; }

function confirmBulkDelete() {
  const deletedRows = [];
  document.querySelectorAll('.dormant-row').forEach(row => {
    const cb = row.querySelector('.row-check');
    if (row.style.display !== 'none' && cb.checked) {
      deletedRows.push(row);
    }
  });

  // TODO: fetch DELETE /admin/member/dormant/bulk { emails: [...] }

  deletedRows.forEach(r => { r.style.display = 'none'; });
  filteredRows = filteredRows.filter(r => !deletedRows.includes(r));

  const kpiEl = document.getElementById('kpiTotalDormant');
  if (kpiEl) kpiEl.textContent = Math.max(0, parseInt(kpiEl.textContent.replace(/,/g, '')) - deletedRows.length);

  onRowCheck();
  currentPage = 1;
  renderPagination(filteredRows.length);
  document.getElementById('resultCount').textContent = '총 ' + filteredRows.length + '명';
  closeBulkDeleteModal();
  alert('✅ ' + deletedRows.length + '명의 개인정보가 파기 처리되었습니다.');
}

/* 메일 발송 */
function sendEmail(email) {
  if (confirm(email + ' 님에게 복귀 안내 메일을 발송하시겠습니까?')) {
    // TODO: fetch POST /admin/member/dormant/mail { email }
    alert('✅ 메일 발송이 요청되었습니다.');
  }
}

function openBulkMailModal() {
  // 체크된 게 있으면 선택 발송, 없으면 조회 전체 발송
  let cnt = 0;
  let isSelected = false;
  document.querySelectorAll('.dormant-row').forEach(row => {
    if (row.style.display !== 'none' && row.querySelector('.row-check').checked) {
      cnt++; isSelected = true;
    }
  });
  if (!isSelected) cnt = filteredRows.length;

  const desc = isSelected
    ? '선택된 ' + cnt + '명에게 발송합니다.'
    : '조회된 전체 ' + cnt + '명에게 발송합니다.';

  document.getElementById('bulkMailDesc').textContent = desc;
  document.getElementById('bulkMailCount').textContent = cnt + '명';
  document.getElementById('bulkMailModal').style.display = 'flex';
}

function closeBulkMailModal() { document.getElementById('bulkMailModal').style.display = 'none'; }

function confirmBulkMail() {
  // TODO: fetch POST /admin/member/dormant/mail/bulk { emails: [...] }
  closeBulkMailModal();
  alert('✅ 일괄 메일 발송이 시작되었습니다.');
}

/* 엑셀 다운로드 */
function downloadDormantExcel(selectedOnly) {
  let rows = [];
  if (selectedOnly) {
    document.querySelectorAll('.dormant-row').forEach(row => {
      const cb = row.querySelector('.row-check');
      if (row.style.display !== 'none' && cb && cb.checked) rows.push(row);
    });
  } else {
    rows = filteredRows;
  }

  if (rows.length === 0) {
    alert('다운로드할 데이터가 없습니다. 먼저 검색을 실행해주세요.');
    return;
  }

  let csv = '\uFEFF' + 'ID(이메일),닉네임,마지막접속일,휴면전환일,파기예정일\n';
  rows.forEach(row => {
    csv += `"${row.dataset.email}","${row.dataset.nickname}","${row.dataset.lastlogin}","${row.dataset.dormantdate}","${row.dataset.deletedate}"\n`;
  });

  const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
  const link = document.createElement('a');
  link.href     = URL.createObjectURL(blob);
  link.download = '휴면회원목록_' + new Date().toISOString().slice(0,10) + '.csv';
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
}

/* ── 오버레이 클릭 닫기 ── */
window.addEventListener('click', e => {
  if (e.target.classList.contains('modal-overlay')) {
    closeDeleteModal();
    closeBulkDeleteModal();
    closeBulkMailModal();
  }
});
</script>
</body>
</html>
