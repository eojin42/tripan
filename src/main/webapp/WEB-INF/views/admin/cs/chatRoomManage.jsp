<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>TripanSuper — 채팅방 관리</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/admin.css">
  <style>
    /* ── 채팅방 관리 전용 추가 스타일 (admin.css 변수 100% 활용) ── */

    /* 메인 2단 그리드 */
    .cr-main-grid {
      display: grid;
      grid-template-columns: 1fr 340px;
      gap: 20px;
      align-items: start;
    }
    @media (max-width: 1200px) { .cr-main-grid { grid-template-columns: 1fr; } }

    /* 테이블 컬럼 */
    .col-dot    { width: 28px; text-align: center; }
    .col-name   { min-width: 140px; }
    .col-type   { width: 100px; }
    .col-region { width: 140px; }
    .col-users  { width: 70px; text-align: right; }
    .col-toggle { width: 68px; }
    .col-action { width: 120px; text-align: right; }

    /* 상태 도트 */
    .cr-dot-on  { display: inline-block; width: 8px; height: 8px; border-radius: 50%;
                  background: var(--success); box-shadow: 0 0 0 2px rgba(16,185,129,.25); }
    .cr-dot-off { display: inline-block; width: 8px; height: 8px; border-radius: 50%;
                  background: var(--muted); }

    /* 토글 스위치 */
    .cr-toggle          { position: relative; display: inline-block; width: 36px; height: 20px; }
    .cr-toggle input    { opacity: 0; width: 0; height: 0; }
    .cr-toggle-slider   {
      position: absolute; inset: 0; background: #D1D5DB;
      border-radius: 20px; cursor: pointer; transition: .2s;
    }
    .cr-toggle-slider::before {
      content: ''; position: absolute; width: 14px; height: 14px;
      background: #fff; border-radius: 50%;
      top: 3px; left: 3px; transition: .2s;
    }
    .cr-toggle input:checked + .cr-toggle-slider { background: var(--primary); }
    .cr-toggle input:checked + .cr-toggle-slider::before { transform: translateX(16px); }

    /* 우측 디테일 패널 */
    .cr-panel-name { font-size: 15px; font-weight: 800; color: var(--text); margin-bottom: 3px; }
    .cr-panel-meta { font-size: 12px; color: var(--muted); }

    .cr-tabs     { display: flex; border-bottom: 1px solid var(--border); padding: 0 24px; margin-bottom: 4px; }
    .cr-tab      {
      background: none; border: none; border-bottom: 2px solid transparent;
      font-size: 13px; color: var(--muted); font-weight: 700;
      padding: 10px 12px; cursor: pointer; transition: .15s; font-family: inherit;
    }
    .cr-tab.active { color: var(--primary); border-bottom-color: var(--primary); }

    .cr-member-row {
      display: flex; align-items: center; gap: 10px;
      padding: 10px 24px; border-bottom: 1px dashed var(--border); transition: .1s;
    }
    .cr-member-row:last-child { border-bottom: none; }
    .cr-member-row:hover { background: rgba(59,110,248,.03); }

    .cr-avatar-sm {
      width: 32px; height: 32px; border-radius: 50%;
      background: var(--primary-10); color: var(--primary);
      display: flex; align-items: center; justify-content: center;
      font-size: 11px; font-weight: 800; flex-shrink: 0;
    }
    .cr-member-name   { flex: 1; font-size: 13px; font-weight: 700; color: var(--text); }
    .cr-member-status { font-size: 11px; color: var(--muted); }

    .cr-msg-item  { padding: 10px 24px; border-bottom: 1px dashed var(--border); }
    .cr-msg-item:last-child { border-bottom: none; }
    .cr-msg-meta  { font-size: 11px; color: var(--muted); font-weight: 700; margin-bottom: 3px; }
    .cr-msg-text  { font-size: 13px; color: var(--text); }

    /* 빈 패널 */
    .cr-empty     { padding: 50px 24px; text-align: center; color: var(--muted); }
    .cr-empty-icon { font-size: 38px; margin-bottom: 14px; opacity: .4; }
    .cr-empty-text { font-size: 13px; line-height: 1.7; }

    /* ── 개설 모달 전용 오버레이 (admin.css .modal-overlay 충돌 방지) ── */
    .cr-modal-overlay {
      position: fixed; inset: 0;
      background: rgba(15,23,42,0.55);
      backdrop-filter: blur(6px); -webkit-backdrop-filter: blur(6px);
      display: none; justify-content: center; align-items: center;
      z-index: 3000; padding: 24px;
    }
    .cr-modal-overlay.open { display: flex; }
    .cr-modal-sheet {
      background: var(--surface); width: 100%; max-width: 480px;
      border-radius: var(--radius-xl); overflow: hidden;
      box-shadow: var(--shadow-lg);
      animation: crModalUp 0.28s cubic-bezier(0.16,1,0.3,1);
      display: flex; flex-direction: column;
    }
    @keyframes crModalUp {
      from { opacity:0; transform:translateY(16px) scale(0.98); }
      to   { opacity:1; transform:translateY(0)    scale(1); }
    }
    .cr-ms-head    { padding: 26px 28px 18px; border-bottom: 1px solid var(--border); }
    .cr-ms-head h3 { font-size: 17px; font-weight: 900; margin: 0 0 4px; color: var(--text); }
    .cr-ms-head p  { font-size: 13px; color: var(--muted); margin: 0; }
    .cr-ms-body    { overflow-y: auto; max-height: 62vh; }
    .cr-ms-foot    { padding: 16px 28px; border-top: 1px solid var(--border); display: flex; gap: 10px; }
    .cr-ms-foot .btn-m {
      flex: 1; height: 46px; border-radius: var(--radius-md);
      font-weight: 700; font-size: 14px; border: none;
      cursor: pointer; transition: opacity .15s; font-family: inherit;
    }
    .cr-ms-foot .btn-m-ghost   { background: var(--bg); color: var(--text); border: 1px solid var(--border); }
    .cr-ms-foot .btn-m-primary { background: var(--text); color: #fff; }
    .cr-ms-foot .btn-m:hover   { opacity: .84; }

    /* 폼 섹션 */
    .cr-form-section { padding: 20px 28px; }
    .cr-form-section + .cr-form-section { border-top: 1px solid var(--border); }
    .cr-section-title {
      font-size: 11px; font-weight: 800; color: var(--muted);
      text-transform: uppercase; letter-spacing: .06em; margin-bottom: 14px;
    }
    .cr-form-row        { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; margin-bottom: 12px; }
    .cr-form-row.full   { grid-template-columns: 1fr; }
    .cr-form-row:last-child { margin-bottom: 0; }

    .cr-form-label {
      display: block; font-size: 11px; font-weight: 800; color: var(--muted);
      text-transform: uppercase; letter-spacing: .05em; margin-bottom: 6px;
    }
    .cr-form-input, .cr-form-select {
      width: 100%; font-size: 13px; height: 40px; padding: 0 14px;
      border: 1.5px solid var(--border); border-radius: var(--radius-md);
      background: var(--bg); color: var(--text);
      font-family: inherit; font-weight: 600; outline: none; transition: .2s;
      box-sizing: border-box;
    }
    .cr-form-input:focus, .cr-form-select:focus {
      border-color: var(--primary);
      box-shadow: 0 0 0 3px var(--primary-10);
      background: var(--surface);
    }
    .cr-form-hint { font-size: 11px; color: var(--muted); margin-top: 5px; }

    /* 채팅방 이름 = 지역prefix + 직접입력 조합 */
    .cr-name-row {
      display: flex; align-items: center; gap: 8px;
    }
    .cr-name-prefix {
      flex-shrink: 0; height: 40px; padding: 0 12px;
      border: 1.5px solid var(--border); border-radius: var(--radius-md);
      background: var(--bg); color: var(--text);
      font-family: inherit; font-size: 13px; font-weight: 600;
      outline: none; transition: .2s; min-width: 120px; max-width: 150px;
      appearance: none; -webkit-appearance: none;
      background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='10' height='6'%3E%3Cpath d='M0 0l5 6 5-6z' fill='%238B92A5'/%3E%3C/svg%3E");
      background-repeat: no-repeat; background-position: right 10px center; padding-right: 28px;
      cursor: pointer;
    }
    .cr-name-prefix:focus { border-color: var(--primary); box-shadow: 0 0 0 3px var(--primary-10); background-color: var(--surface); }
    .cr-name-sep { font-size: 16px; color: var(--muted); font-weight: 700; flex-shrink: 0; }
    .cr-name-input {
      flex: 1; height: 40px; padding: 0 14px;
      border: 1.5px solid var(--border); border-radius: var(--radius-md);
      background: var(--bg); color: var(--text);
      font-family: inherit; font-size: 13px; font-weight: 600;
      outline: none; transition: .2s; box-sizing: border-box;
    }
    .cr-name-input:focus { border-color: var(--primary); box-shadow: 0 0 0 3px var(--primary-10); background: var(--surface); }

    /* 이름 미리보기 */
    .cr-name-preview {
      margin-top: 8px; padding: 8px 12px;
      background: var(--primary-10); border-radius: var(--radius-sm);
      font-size: 12px; font-weight: 700; color: var(--primary);
      display: none;
    }
    .cr-name-preview.visible { display: block; }

    .cr-toggle-row  {
      display: flex; align-items: center; justify-content: space-between; padding: 10px 0;
    }
    .cr-toggle-label { font-size: 13px; font-weight: 700; color: var(--text); }
    .cr-toggle-sub   { font-size: 11px; color: var(--muted); margin-top: 2px; }

    /* 페이지네이션 */
    .cr-pagination { display: flex; justify-content: center; gap: 4px; padding: 14px; border-top: 1px solid var(--border); }

    /* 선택된 행 */
    tbody tr.cr-selected td { background: rgba(59,110,248,.05); }
  </style>
</head>
<body>

<div class="admin-layout">
  <jsp:include page="../layout/sidebar.jsp">
    <jsp:param name="activePage" value="chatrooms"/>
  </jsp:include>

  <div class="main-wrapper">
    <jsp:include page="../layout/header.jsp" />

    <main class="main-content">

      <!-- ── 페이지 헤더 ── -->
      <div class="page-header fade-up">
        <div>
          <h1>채팅방 관리</h1>
          <p>라운지 채팅방 개설 및 운영 관리</p>
        </div>
        <button class="btn btn-primary" onclick="crOpenModal()">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
          새 채팅방 개설
        </button>
      </div>

      <!-- ── KPI 카드 ── -->
      <div class="kpi-grid">
        <div class="card kpi-card fade-up fade-up-1">
          <div class="kpi-label">전체 채팅방</div>
          <div class="kpi-value" id="statTotal">-</div>
          <div class="kpi-sub" id="statTotalSub">지역 - / CS -</div>
        </div>
        <div class="card kpi-card fade-up fade-up-2">
          <div class="kpi-label">활성 채팅방</div>
          <div class="kpi-value" id="statActive" style="color:var(--success);">-</div>
          <div class="kpi-sub" id="statActiveSub">지역 - / CS -</div>
        </div>
        <div class="card kpi-card fade-up fade-up-3">
          <div class="kpi-label">현재 접속자</div>
          <div class="kpi-value" id="statUsers" style="color:var(--primary);">-</div>
          <div class="kpi-sub">전체 라운지 합산</div>
        </div>
        <div class="card kpi-card fade-up fade-up-4">
          <div class="kpi-label">오늘 메시지</div>
          <div class="kpi-value" id="statMessages">-</div>
          <div class="kpi-sub">금일 발송 총합</div>
        </div>
      </div>

      <!-- ── 필터 카드 ── -->
      <div class="card filter-card fade-up">
        <div class="filter-row">
          <div class="filter-label">채팅방 검색</div>
          <select class="filter-select" id="filterType" onchange="crFilter()" style="width:130px;">
            <option value="">전체 타입</option>
            <option value="REGION">REGION</option>
            <option value="SUPPORT">SUPPORT</option>
          </select>
          <select class="filter-select" id="filterStatus" onchange="crFilter()" style="width:120px;">
            <option value="">전체 상태</option>
            <option value="ACTIVE">활성</option>
            <option value="CLOSED">비활성</option>
          </select>
          <input type="text" id="searchInput" class="keyword-input"
                 placeholder="채팅방 이름 검색..."
                 onkeyup="if(event.key==='Enter') crFilter()">
          <div class="filter-actions">
            <button class="btn btn-ghost btn-sm" onclick="crResetFilter()">
              <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="1 4 1 10 7 10"/><path d="M3.51 15a9 9 0 1 0 .49-3.51"/></svg>
              초기화
            </button>
            <button class="btn btn-primary btn-sm" onclick="crFilter()">
              <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
              검색
            </button>
          </div>
        </div>
      </div>

      <!-- ── 메인 그리드 ── -->
      <div class="cr-main-grid fade-up">

        <!-- 채팅방 목록 -->
        <div class="card table-card">
          <div class="w-header">
            <h2 style="display:inline-flex;align-items:center;gap:8px;">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
              채팅방 목록
            </h2>
            <span id="totalCount" style="font-size:12px;color:var(--muted);font-weight:700;">총 0개</span>
          </div>
          <div class="table-responsive">
            <table>
              <thead>
                <tr>
                  <th class="col-dot"></th>
                  <th class="col-name">방 이름</th>
                  <th class="col-type">타입</th>
                  <th class="col-region">지역</th>
                  <th class="col-users right">접속자</th>
                  <th class="col-toggle">활성</th>
                  <th class="col-action right">관리</th>
                </tr>
              </thead>
              <tbody id="roomTableBody">
                <tr><td colspan="7" style="text-align:center;padding:40px;color:var(--muted);">불러오는 중...</td></tr>
              </tbody>
            </table>
          </div>
          <div class="cr-pagination" id="paginationArea"></div>
        </div>

        <!-- 우측 디테일 패널 -->
        <div id="detailPanel" style="display:none;">
          <div class="card" style="overflow:hidden;">
            <div style="padding:20px 24px; border-bottom:1px solid var(--border);">
              <div class="cr-panel-name" id="detailRoomName">-</div>
              <div class="cr-panel-meta" id="detailRoomMeta">-</div>
            </div>
            <div class="cr-tabs">
              <button class="cr-tab active" onclick="crSwitchTab(this,'members')">입장 멤버</button>
              <button class="cr-tab"        onclick="crSwitchTab(this,'messages')">채팅 내역</button>
            </div>
            <div id="tabMembers"></div>
            <div id="tabMessages" style="display:none;">
              <div style="padding:10px 20px; border-bottom:1px solid var(--border); display:flex; gap:8px; align-items:center;">
                <input type="date" id="msgDateFilter" class="filter-select" style="height:32px;font-size:12px;width:140px;"
                       onchange="crLoadMessagesByDate()" />
                <button class="btn btn-ghost btn-sm" style="height:32px;font-size:12px;" onclick="crClearDateFilter()">전체</button>
                <span id="msgCount" style="font-size:11px;color:var(--muted);margin-left:auto;"></span>
              </div>
              <div id="tabMessagesInner"
                   style="overflow-y:auto; max-height:420px;"></div>
            </div>
          </div>
        </div>

        <!-- 빈 패널 -->
        <div id="emptyPanel">
          <div class="card">
            <div class="cr-empty">
              <div class="cr-empty-icon">
                <svg width="38" height="38" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" style="opacity:.35;"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
              </div>
              <div class="cr-empty-text">채팅방을 선택하면<br>멤버 및 채팅 내역을 확인할 수 있어요</div>
            </div>
          </div>
        </div>

      </div>

    </main>
  </div>
</div>


<!-- ══════════════════════════════════════
     개설 모달 — 전용 클래스(cr-modal-*)로 admin.css 충돌 방지
══════════════════════════════════════ -->
<div class="cr-modal-overlay" id="crCreateModal">
  <div class="cr-modal-sheet">

    <div class="cr-ms-head">
      <h3>새 채팅방 개설</h3>
      <p>개설 즉시 프론트엔드 라운지 목록에 반영됩니다.</p>
    </div>

    <div class="cr-ms-body">

      <!-- 채팅방 이름: 지역 prefix 드롭박스 + 직접입력 -->
      <div class="cr-form-section">
        <div class="cr-section-title">채팅방 이름</div>
        <div>
          <label class="cr-form-label">지역 + 방 이름 <span style="color:var(--danger);">*</span></label>
          <div class="cr-name-row">
            <select id="formNamePrefix" class="cr-name-prefix" onchange="crUpdatePreview()">
              <option value="">지역 선택</option>
              <option value="서울">서울</option>
              <option value="부산">부산</option>
              <option value="인천">인천</option>
              <option value="대구">대구</option>
              <option value="대전">대전</option>
              <option value="광주">광주</option>
              <option value="울산">울산</option>
              <option value="세종">세종</option>
              <option value="경기">경기</option>
              <option value="강원">강원</option>
              <option value="충북">충북</option>
              <option value="충남">충남</option>
              <option value="전북">전북</option>
              <option value="전남">전남</option>
              <option value="경북">경북</option>
              <option value="경남">경남</option>
              <option value="제주">제주</option>
            </select>
            <span class="cr-name-sep">·</span>
            <input type="text" id="formRoomSuffix" class="cr-name-input"
                   placeholder="동행/맛집 방" maxlength="50"
                   oninput="crUpdatePreview()" />
          </div>
          <div class="cr-name-preview" id="namePreview"></div>
          <div class="cr-form-hint">완성된 채팅방 이름이 프론트 목록에 표시돼요</div>
        </div>
      </div>

      <!-- 지역 연결 (regionId) -->
      <div class="cr-form-section">
        <div class="cr-section-title">지역 연결</div>
        <div class="cr-form-row">
          <div>
            <label class="cr-form-label">시/도</label>
            <select id="formSido" class="cr-form-select" onchange="crLoadSigungu()">
              <option value="">선택 (전체)</option>
            </select>
          </div>
          <div>
            <label class="cr-form-label">시/군/구</label>
            <select id="formSigungu" class="cr-form-select">
              <option value="">전체 (시/도 라운지)</option>
            </select>
          </div>
        </div>
        <div class="cr-form-hint">region 테이블 연결 — 비워두면 시/도 전체 라운지로 개설돼요</div>
      </div>

      <!-- 초기 설정 -->
      <div class="cr-form-section">
        <div class="cr-section-title">초기 설정</div>
        <div class="cr-toggle-row">
          <div>
            <div class="cr-toggle-label">개설 후 즉시 활성화</div>
            <div class="cr-toggle-sub">비활성화하면 프론트에 노출되지 않아요</div>
          </div>
          <label class="cr-toggle">
            <input type="checkbox" id="formActive" checked />
            <span class="cr-toggle-slider"></span>
          </label>
        </div>
      </div>

    </div>

    <div class="cr-ms-foot">
      <button class="btn-m btn-m-ghost" onclick="crCloseModal()">취소</button>
      <button class="btn-m btn-m-primary" onclick="crSubmitCreate()">채팅방 개설</button>
    </div>

  </div>
</div>


<!-- ══════════════════════════════════════
     JavaScript
══════════════════════════════════════ -->
<script>
(function () {
  var CTX        = '${pageContext.request.contextPath}';
  var allRooms   = [];
  var filtered   = [];
  var page       = 1;
  var PAGE_SIZE  = 10;
  var selectedId = null;

  /* ── 초기화 ── */
  function init() {
    loadSido();
    loadRooms();
    loadStats();
  }

  /* ── 통계 ── */
  function loadStats() {
    fetch(CTX + '/admin/api/chat/rooms/stats')
      .then(function (r) { return r.json(); })
      .then(function (d) {
        document.getElementById('statTotal').textContent    = d.total    || 0;
        document.getElementById('statActive').textContent   = d.active   || 0;
        document.getElementById('statUsers').textContent    = (d.onlineUsers   || 0) + '명';
        document.getElementById('statMessages').textContent = (d.todayMessages || 0).toLocaleString();
        document.getElementById('statTotalSub').textContent  = '지역 ' + (d.totalRegion || 0) + '개 / WS ' + (d.totalCs || 0) + '개';
        document.getElementById('statActiveSub').textContent = '지역 ' + (d.activeRegion || 0) + '개 / WS ' + (d.activeCs || 0) + '개';
      }).catch(function () {});
  }

  /* ── 채팅방 목록 ── */
  function loadRooms() {
    fetch(CTX + '/admin/api/chat/rooms')
      .then(function (r) { return r.json(); })
      .then(function (data) {
        allRooms = data || [];
        crFilter();
      })
      .catch(function () {
        document.getElementById('roomTableBody').innerHTML =
          '<tr><td colspan="7" style="text-align:center;padding:40px;color:var(--danger);">목록을 불러오지 못했습니다.</td></tr>';
      });
  }

  /* ── 필터 ── */
  window.crFilter = function () {
    var kw     = document.getElementById('searchInput').value.toLowerCase();
    var type   = document.getElementById('filterType').value;
    var status = document.getElementById('filterStatus').value;

    filtered = allRooms.filter(function (r) {
      var okName   = !kw     || (r.chatRoomName || '').toLowerCase().includes(kw);
      var okType   = !type   || r.chatRoomType === type;
      var okStatus = status === '' || r.status === status;
      return okName && okType && okStatus;
    });
    page = 1;
    renderTable();
  };

  window.crResetFilter = function () {
    document.getElementById('searchInput').value  = '';
    document.getElementById('filterType').value   = '';
    document.getElementById('filterStatus').value = '';
    crFilter();
  };

  /* ── 테이블 렌더링 ── */
  function renderTable() {
    var tbody = document.getElementById('roomTableBody');
    var total = filtered.length;
    document.getElementById('totalCount').textContent = '총 ' + total + '개';

    if (total === 0) {
      tbody.innerHTML = '<tr><td colspan="7" style="text-align:center;padding:40px;color:var(--muted);">채팅방이 없습니다.</td></tr>';
      document.getElementById('paginationArea').innerHTML = '';
      return;
    }

    var start = (page - 1) * PAGE_SIZE;
    var paged = filtered.slice(start, start + PAGE_SIZE);

    tbody.innerHTML = paged.map(function (r) {
      var isOn   = r.status === 'ACTIVE';
      var region = r.sidoName
        ? (r.sidoName + (r.sigunguName ? ' ' + r.sigunguName : ''))
        : '-';
      var sel = r.chatRoomId === selectedId ? ' cr-selected' : '';

      return '<tr class="' + sel + '" onclick="crSelectRoom(' + r.chatRoomId + ')" style="cursor:pointer;">' +
        '<td class="col-dot"><span class="' + (isOn ? 'cr-dot-on' : 'cr-dot-off') + '"></span></td>' +
        '<td class="col-name" style="font-weight:700;max-width:140px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;" title="' + escHtml(r.chatRoomName||'') + '">' + escHtml(r.chatRoomName || '-') + '</td>' +
        '<td class="col-type"><span class="badge" style="background:#EFF6FF;color:#1D4ED8;">' + escHtml(r.chatRoomType || '-') + '</span></td>' +
        '<td class="col-region num" style="font-size:12px;color:var(--muted);max-width:140px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">' + escHtml(region) + '</td>' +
        '<td class="col-users right num">' + (r.onlineCount || 0) + '</td>' +
        '<td class="col-toggle">' +
          '<label class="cr-toggle" onclick="event.stopPropagation();">' +
            '<input type="checkbox"' + (isOn ? ' checked' : '') +
            ' onchange="crToggleStatus(' + r.chatRoomId + ',this)" />' +
            '<span class="cr-toggle-slider"></span>' +
          '</label>' +
        '</td>' +
        '<td class="col-action right">' +
          '<div style="display:inline-flex;gap:6px;">' +
            '<button class="btn btn-ghost btn-sm" onclick="event.stopPropagation();crSelectRoom(' + r.chatRoomId + ')">상세</button>' +
            '<button class="btn btn-sm" style="background:#FEF2F2;color:var(--danger);" onclick="event.stopPropagation();crDeleteRoom(' + r.chatRoomId + ')">삭제</button>' +
          '</div>' +
        '</td>' +
      '</tr>';
    }).join('');

    renderPagination(total);
  }

  /* ── 페이지네이션 ── */
  function renderPagination(total) {
    var totalPages = Math.ceil(total / PAGE_SIZE);
    var area = document.getElementById('paginationArea');
    if (totalPages <= 1) { area.innerHTML = ''; return; }
    var html = '';
    for (var i = 1; i <= totalPages; i++) {
      html += '<button class="pg-btn' + (i === page ? ' active' : '') +
              '" onclick="crGoPage(' + i + ')">' + i + '</button>';
    }
    area.innerHTML = html;
  }
  window.crGoPage = function (p) { page = p; renderTable(); };

  /* ── 행 선택 / 상세 패널 ── */
  window.crSelectRoom = function (roomId) {
    selectedId = roomId;
    renderTable();

    var r = allRooms.find(function (x) { return x.chatRoomId === roomId; });
    if (!r) return;

    var region = r.sidoName
      ? (r.sidoName + (r.sigunguName ? ' · ' + r.sigunguName : ' 전체'))
      : '지역 없음';
    var isOn = r.status === 1 || r.status === '1';

    document.getElementById('detailRoomName').textContent = r.chatRoomName || '-';
    document.getElementById('detailRoomMeta').textContent =
      (r.chatRoomType || '') + ' · ' + region + ' · ' + (isOn ? '활성' : '비활성');

    document.getElementById('detailPanel').style.display = '';
    document.getElementById('emptyPanel').style.display  = 'none';

    loadMembers(roomId);
    loadMessages(roomId);

    document.querySelectorAll('.cr-tab').forEach(function (t) {
      t.classList.toggle('active', t.textContent.trim() === '입장 멤버');
    });
    document.getElementById('tabMembers').style.display  = '';
    document.getElementById('tabMessages').style.display = 'none';
  };

  /* ── 탭 전환 ── */
  window.crSwitchTab = function (btn, tab) {
    document.querySelectorAll('.cr-tab').forEach(function (t) { t.classList.remove('active'); });
    btn.classList.add('active');
    document.getElementById('tabMembers').style.display  = tab === 'members'  ? '' : 'none';
    document.getElementById('tabMessages').style.display = tab === 'messages' ? '' : 'none';
  };

  /* ── 멤버 목록 ── */
  function loadMembers(roomId) {
    var el = document.getElementById('tabMembers');
    el.innerHTML = '<div style="padding:24px;text-align:center;color:var(--muted);font-size:13px;">불러오는 중...</div>';
    fetch(CTX + '/admin/api/chat/rooms/' + roomId + '/members')
      .then(function (r) { return r.json(); })
      .then(function (list) {
        if (!list || list.length === 0) {
          el.innerHTML = '<div style="padding:24px;text-align:center;color:var(--muted);font-size:13px;">입장 멤버가 없습니다.</div>';
          return;
        }
        el.innerHTML = list.map(function (m) {
          var ini     = (m.nickname || 'NN').substring(0, 2).toUpperCase();
          var online  = m.connStatus === 'ONLINE';
          var blocked = m.adminStatus === 'BLOCKED';
          return '<div class="cr-member-row">' +
            '<div class="cr-avatar-sm">' + ini + '</div>' +
            '<div style="flex:1;min-width:0;">' +
              '<div class="cr-member-name">' + escHtml(m.nickname || '-') + '</div>' +
              '<div class="cr-member-status" style="color:' + (online ? 'var(--success)' : 'var(--muted)') + ';">' +
                (online ? '● 접속 중' : '○ 오프라인') +
              '</div>' +
            '</div>' +
            '<div style="display:flex;gap:5px;flex-shrink:0;">' +
              (blocked
                ? '<span class="badge badge-danger">차단됨</span>'
                : '<button class="btn btn-ghost btn-sm" onclick="crKickMember(' + roomId + ',' + m.memberId + ')">강퇴</button>' +
                  '<button class="btn btn-sm" style="background:#FEF2F2;color:var(--danger);" onclick="crBlockMember(' + roomId + ',' + m.memberId + ')">차단</button>'
              ) +
            '</div>' +
          '</div>';
        }).join('');
      })
      .catch(function () {
        el.innerHTML = '<div style="padding:24px;text-align:center;color:var(--danger);font-size:13px;">불러오지 못했습니다.</div>';
      });
  }

  /* ── 채팅 내역 ── */
  var currentMsgRoomId = null;

  function loadMessages(roomId, searchDate) {
    currentMsgRoomId = roomId;
    var inner = document.getElementById('tabMessagesInner');
    var countEl = document.getElementById('msgCount');
    inner.innerHTML = '<div style="padding:24px;text-align:center;color:var(--muted);font-size:13px;">불러오는 중...</div>';

    var url = CTX + '/admin/api/chat/rooms/' + roomId + '/messages?size=100';
    if (searchDate) url += '&searchDate=' + searchDate;

    fetch(url)
      .then(function (r) { return r.json(); })
      .then(function (list) {
        if (!list || list.length === 0) {
          inner.innerHTML = '<div style="padding:24px;text-align:center;color:var(--muted);font-size:13px;">채팅 내역이 없습니다.</div>';
          if (countEl) countEl.textContent = '';
          return;
        }

        if (countEl) countEl.textContent = '총 ' + list.length + '건';

        /* 날짜별 그룹핑 */
        var grouped = {};
        var dateOrder = [];
        list.forEach(function (msg) {
          var date = (msg.createdAt || '').substring(0, 10) || '날짜 없음';
          if (!grouped[date]) { grouped[date] = []; dateOrder.push(date); }
          grouped[date].push(msg);
        });

        inner.innerHTML = dateOrder.map(function (date) {
          var msgs = grouped[date].map(function (msg) {
            return '<div class="cr-msg-item">' +
              '<div class="cr-msg-meta">' +
                escHtml(msg.senderNickname || '-') + ' · ' +
                escHtml((msg.createdAt || '').substring(11, 16)) +
              '</div>' +
              '<div class="cr-msg-text">' + escHtml(msg.content || '') + '</div>' +
            '</div>';
          }).join('');

          return '<div style="position:sticky;top:0;background:var(--bg);padding:6px 20px;' +
                 'font-size:11px;font-weight:800;color:var(--muted);border-bottom:1px solid var(--border);z-index:1;">' +
                 date + '</div>' + msgs;
        }).join('');

        /* 맨 아래로 스크롤 */
        inner.scrollTop = inner.scrollHeight;
      })
      .catch(function () {
        inner.innerHTML = '<div style="padding:24px;text-align:center;color:var(--danger);font-size:13px;">불러오지 못했습니다.</div>';
      });
  }

  window.crLoadMessagesByDate = function () {
    var date = document.getElementById('msgDateFilter').value;
    if (currentMsgRoomId) loadMessages(currentMsgRoomId, date || null);
  };

  window.crClearDateFilter = function () {
    document.getElementById('msgDateFilter').value = '';
    if (currentMsgRoomId) loadMessages(currentMsgRoomId, null);
  };

  /* ── 활성/비활성 토글 ── */
  window.crToggleStatus = function (roomId, cb) {
    var status = cb.checked ? 'ACTIVE' : 'CLOSED';
    fetch(CTX + '/admin/api/chat/rooms/' + roomId + '/status', {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ status: status })
    })
    .then(function (r) { if (!r.ok) throw new Error(); })
    .then(function () {
      var found = allRooms.find(function (x) { return x.chatRoomId === roomId; });
      if (found) { found.status = status; crFilter(); }
      if (selectedId === roomId) crSelectRoom(roomId);
    })
    .catch(function () { alert('상태 변경에 실패했습니다.'); cb.checked = !cb.checked; });
  };

  /* ── 삭제 ── */
  window.crDeleteRoom = function (roomId) {
    if (!confirm('채팅방을 삭제하시겠습니까?\n대화 내역도 모두 삭제됩니다.')) return;
    fetch(CTX + '/admin/api/chat/rooms/' + roomId, { method: 'DELETE' })
      .then(function (r) { if (!r.ok) throw new Error(); })
      .then(function () {
        allRooms = allRooms.filter(function (x) { return x.chatRoomId !== roomId; });
        if (selectedId === roomId) {
          selectedId = null;
          document.getElementById('detailPanel').style.display = 'none';
          document.getElementById('emptyPanel').style.display  = '';
        }
        crFilter(); loadStats();
      })
      .catch(function () { alert('삭제에 실패했습니다.'); });
  };

  /* ── 강퇴 / 차단 ── */
  window.crKickMember = function (roomId, memberId) {
    if (!confirm('해당 멤버를 강퇴하시겠습니까?')) return;
    fetch(CTX + '/admin/api/chat/rooms/' + roomId + '/members/' + memberId + '/kick', { method: 'POST' })
      .then(function (r) { if (!r.ok) throw new Error(); loadMembers(roomId); })
      .catch(function () { alert('강퇴에 실패했습니다.'); });
  };
  window.crBlockMember = function (roomId, memberId) {
    if (!confirm('해당 멤버를 영구 차단하시겠습니까?')) return;
    fetch(CTX + '/admin/api/chat/rooms/' + roomId + '/members/' + memberId + '/block', { method: 'POST' })
      .then(function (r) { if (!r.ok) throw new Error(); loadMembers(roomId); })
      .catch(function () { alert('차단에 실패했습니다.'); });
  };

  /* ── 지역 드롭다운 ── */
  function loadSido() {
    fetch(CTX + '/api/regions/sido')
      .then(function (r) { return r.json(); })
      .then(function (list) {
        var sel = document.getElementById('formSido');
        sel.innerHTML = '<option value="">선택 (전체)</option>';
        (list || []).forEach(function (s) {
          sel.insertAdjacentHTML('beforeend',
            '<option value="' + s.regionId + '">' + escHtml(s.sidoName) + '</option>');
        });
      }).catch(function () {});
  }
  window.crLoadSigungu = function () {
    var sidoId = document.getElementById('formSido').value;
    var sel    = document.getElementById('formSigungu');
    sel.innerHTML = '<option value="">전체 (시/도 라운지)</option>';
    if (!sidoId) return;
    fetch(CTX + '/api/regions/sigungu?sidoId=' + sidoId)
      .then(function (r) { return r.json(); })
      .then(function (list) {
        (list || []).forEach(function (s) {
          sel.insertAdjacentHTML('beforeend',
            '<option value="' + s.regionId + '">' + escHtml(s.sigunguName) + '</option>');
        });
      }).catch(function () {});
  };

  /* ── 이름 미리보기 ── */
  window.crUpdatePreview = function () {
    var prefix  = document.getElementById('formNamePrefix').value;
    var suffix  = document.getElementById('formRoomSuffix').value.trim();
    var preview = document.getElementById('namePreview');
    if (suffix) {
      var full = prefix ? (prefix + ' ' + suffix) : suffix;
      preview.textContent = '채팅방 이름: ' + full;
      preview.classList.add('visible');
    } else {
      preview.classList.remove('visible');
    }
  };

  /* ── 모달 ── */
  window.crOpenModal = function () {
    document.getElementById('formNamePrefix').value  = '';
    document.getElementById('formRoomSuffix').value  = '';
    document.getElementById('formSido').value        = '';
    document.getElementById('formSigungu').innerHTML = '<option value="">전체 (시/도 라운지)</option>';
    document.getElementById('formActive').checked    = true;
    document.getElementById('namePreview').classList.remove('visible');
    document.getElementById('crCreateModal').classList.add('open');
  };
  window.crCloseModal = function () {
    document.getElementById('crCreateModal').classList.remove('open');
  };
  document.getElementById('crCreateModal').addEventListener('click', function (e) {
    if (e.target === this) crCloseModal();
  });

  /* ── 개설 제출 ── */
  window.crSubmitCreate = function () {
    var prefix  = document.getElementById('formNamePrefix').value;
    var suffix  = document.getElementById('formRoomSuffix').value.trim();
    var sido    = document.getElementById('formSido').value;
    var sigungu = document.getElementById('formSigungu').value;
    var active  = document.getElementById('formActive').checked;

    if (!suffix) { alert('채팅방 이름을 입력해주세요.'); return; }

    var fullName = prefix ? (prefix + ' ' + suffix) : suffix;

    fetch(CTX + '/admin/api/chat/rooms', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        chatRoomName: fullName,
        chatRoomType: 'REGION',
        regionId:     (sigungu || sido) ? Number(sigungu || sido) : null,
        status:       active ? 1 : 0
      })
    })
    .then(function (r) { if (!r.ok) throw new Error(); return r.json(); })
    .then(function () { crCloseModal(); loadRooms(); loadStats(); alert('채팅방이 개설되었습니다.'); })
    .catch(function () { alert('채팅방 개설에 실패했습니다.'); });
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
