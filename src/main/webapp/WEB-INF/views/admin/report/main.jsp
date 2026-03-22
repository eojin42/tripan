<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>TripanSuper — 신고 관리</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/admin.css">
  <style>
    .tab-bar { display:flex; gap:4px; border-bottom:2px solid var(--border); margin-bottom:20px; }
    .tab-btn { padding:10px 18px; font-size:14px; font-weight:700; border:none; background:none; cursor:pointer; color:var(--muted); border-bottom:2px solid transparent; margin-bottom:-2px; transition:all .15s; border-radius:6px 6px 0 0; }
    .tab-btn:hover  { color:var(--text); background:var(--bg); }
    .tab-btn.active { color:var(--primary); border-bottom-color:var(--primary); background:none; }

    .sub-tab-bar { display:none; gap:6px; margin-bottom:16px; }
    .sub-tab-bar.visible { display:flex; }
    .sub-tab-btn { padding:6px 14px; font-size:13px; font-weight:600; border:1.5px solid var(--border); background:var(--bg); cursor:pointer; color:var(--muted); border-radius:20px; transition:all .15s; }
    .sub-tab-btn:hover  { border-color:var(--primary); color:var(--primary); }
    .sub-tab-btn.active { background:var(--primary); color:#fff; border-color:var(--primary); }

    .badge-type              { padding:3px 10px; border-radius:20px; font-size:12px; font-weight:700; }
    .badge-FEED              { background:#dbeafe; color:#1d4ed8; }
    .badge-FEED_COMMENT      { background:#e0e7ff; color:#4338ca; }
    .badge-FREEBOARD         { background:#d1fae5; color:#065f46; }
    .badge-FREEBOARD_COMMENT { background:#a7f3d0; color:#065f46; }
    .badge-MATE              { background:#fef3c7; color:#92400e; }
    .badge-MATE_COMMENT      { background:#fed7aa; color:#9a3412; }
    .badge-PENDING           { background:#fef9c3; color:#854d0e; }
    .badge-PROCESSED         { background:#dcfce7; color:#166534; }
    .badge-inactive          { background:#fee2e2; color:#991b1b; }

    th.sortable { cursor:pointer; user-select:none; }
    th.sortable:hover { color:var(--primary); }
    .sort-icon { margin-left:4px; font-size:11px; }
    th.sortable.asc  .sort-icon::after { content:'↑'; color:var(--primary); }
    th.sortable.desc .sort-icon::after { content:'↓'; color:var(--primary); }
    th.sortable:not(.asc):not(.desc) .sort-icon::after { content:'↕'; color:var(--muted); }

    /* 콘텐츠 아코디언 */
    .content-row { cursor:pointer; transition:background .15s; }
    .content-row:hover td { background:var(--bg); }
    .content-row.open td  { background:var(--bg); font-weight:600; }
    .accordion-row { display:none; }
    .accordion-row.open { display:table-row; }
    .accordion-inner { border-top:2px solid #BFDBFE; border-bottom:2px solid #BFDBFE; }
    .accordion-inner table { width:100%; border-collapse:collapse; font-size:13px; }
    .accordion-inner th { padding:8px 14px; font-weight:700; color:#1D4ED8; font-size:11px; border-bottom:1px solid #BFDBFE; text-align:left; background:#DBEAFE; text-transform:uppercase; letter-spacing:.04em; }
    .accordion-inner td { padding:10px 14px; border-bottom:1px dashed #BFDBFE; background:#F0F7FF; }
    .accordion-inner tr:last-child td { border-bottom:none; }
    .expand-icon { float:right; transition:transform .2s; font-size:11px; color:var(--muted); }
    .content-row.open .expand-icon { transform:rotate(180deg); }
    .content-preview { max-width:200px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; color:var(--muted); font-size:13px; }

    /* 이용자별 아코디언 — 콘텐츠 아코디언과 동일 색으로 통일 */
    .user-row { cursor:pointer; transition:background .15s; }
    .user-row:hover td { background:var(--bg); }
    .user-row.open td  { background:var(--bg); font-weight:700; }
    .user-accordion-row { display:none; }
    .user-accordion-row.open { display:table-row; }
    .user-accordion-inner { border-top:2px solid #BFDBFE; border-bottom:2px solid #BFDBFE; }
    .user-accordion-inner table { width:100%; border-collapse:collapse; font-size:13px; }
    .user-accordion-inner th { padding:8px 14px; font-weight:700; color:#1D4ED8; font-size:11px; border-bottom:1px solid #BFDBFE; text-align:left; background:#DBEAFE; text-transform:uppercase; letter-spacing:.04em; }
    .user-accordion-inner td { padding:10px 14px; border-bottom:1px dashed #BFDBFE; background:#F0F7FF; }
    .user-accordion-inner tr:last-child td { border-bottom:none; }
    .content-full { max-width:240px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; color:var(--muted); }
    .link-btn { display:inline-block; padding:3px 10px; font-size:12px; font-weight:600; background:#e0e7ff; color:#4338ca; border-radius:6px; text-decoration:none; cursor:pointer; border:none; }
    .link-btn:hover { background:#c7d2fe; }

    /* 콘텐츠 전체 보기 모달 */
    .view-modal-sheet { background:#fff; width:100%; max-width:720px; border-radius:20px; overflow:hidden; box-shadow:0 24px 64px rgba(0,0,0,.16); display:flex; flex-direction:column; max-height:85vh; }
    .view-modal-content { padding:0 26px 20px; overflow-y:auto; flex:1; }
    .view-post-box { background:var(--bg); border:1px solid var(--border); border-radius:12px; padding:20px; font-size:14px; line-height:1.8; color:var(--text); white-space:pre-wrap; word-break:break-all; margin-bottom:20px; }
    .view-comment-item { padding:12px 16px; border-bottom:1px dashed var(--border); font-size:13px; }
    .view-comment-item:last-child { border-bottom:none; }
    .view-comment-author { font-weight:700; color:var(--text); font-size:12px; margin-bottom:4px; }
    .view-comment-text { color:var(--text); line-height:1.6; }
    .view-comment-reported { background:#FEF2F2; border-left:3px solid var(--danger); padding-left:12px; border-radius:0 8px 8px 0; }

    /* 모달 */
    .modal-overlay { position:fixed; inset:0; background:rgba(15,23,42,.5); backdrop-filter:blur(4px); display:none; justify-content:center; align-items:center; z-index:3000; padding:24px; }
    .modal-overlay.open { display:flex; }
    .modal-sheet { background:#fff; width:100%; max-width:560px; border-radius:20px; overflow:hidden; box-shadow:0 24px 64px rgba(0,0,0,.16); display:flex; flex-direction:column; max-height:80vh; }
    .ms-head { padding:22px 26px 16px; border-bottom:1px solid var(--border); display:flex; justify-content:space-between; align-items:flex-start; }
    .ms-head h3 { font-size:17px; font-weight:900; margin:0 0 4px; }
    .ms-head p  { font-size:13px; color:var(--muted); margin:0; }
    .ms-close { background:none; border:none; font-size:20px; cursor:pointer; color:var(--muted); line-height:1; padding:4px; }
    .ms-body { padding:22px 26px; overflow-y:auto; flex:1; }
    .ms-content-box { background:var(--bg); border:1px solid var(--border); border-radius:12px; padding:16px; font-size:14px; line-height:1.7; color:var(--text); white-space:pre-wrap; word-break:break-all; max-height:200px; overflow-y:auto; }
    .ms-meta { display:flex; gap:8px; flex-wrap:wrap; margin-bottom:14px; }
    .ms-foot { padding:16px 26px; border-top:1px solid var(--border); display:flex; gap:10px; justify-content:flex-end; }
    .btn-deactivate { background:#dc2626; color:#fff; border:none; border-radius:10px; padding:10px 20px; font-size:14px; font-weight:700; cursor:pointer; }
    .btn-deactivate:hover { background:#b91c1c; }
    .btn-deactivate:disabled { background:#d1d5db; cursor:not-allowed; }
  </style>
</head>
<body>

<div class="admin-layout">
  <jsp:include page="../layout/sidebar.jsp"><jsp:param name="activePage" value="reports"/></jsp:include>
  <div class="main-wrapper">
    <jsp:include page="../layout/header.jsp" />
    <main class="main-content">

      <div class="page-header fade-up">
        <div><h1>신고 관리</h1><p>커뮤니티 신고 내역을 확인하고 콘텐츠를 관리합니다.</p></div>
      </div>

      <!-- 대탭 -->
      <div class="tab-bar fade-up">
        <button class="tab-btn" id="tab-all"       data-tab="all">전체</button>
        <button class="tab-btn" id="tab-user"      data-tab="user">이용자별</button>
        <button class="tab-btn" id="tab-freeboard" data-tab="freeboard">자유게시판</button>
        <button class="tab-btn" id="tab-feed"      data-tab="feed">피드</button>
        <button class="tab-btn" id="tab-mate"      data-tab="mate">동행</button>
      </div>

      <!-- 소탭 -->
      <div class="sub-tab-bar" id="sub-freeboard">
        <button class="sub-tab-btn" data-sub="FREEBOARD">자유게시판</button>
        <button class="sub-tab-btn" data-sub="FREEBOARD_COMMENT">댓글</button>
      </div>
      <div class="sub-tab-bar" id="sub-feed">
        <button class="sub-tab-btn" data-sub="FEED">피드</button>
        <button class="sub-tab-btn" data-sub="FEED_COMMENT">피드 댓글</button>
      </div>
      <div class="sub-tab-bar" id="sub-mate">
        <button class="sub-tab-btn" data-sub="MATE">동행</button>
        <button class="sub-tab-btn" data-sub="MATE_COMMENT">댓글</button>
      </div>

      <!-- 필터 -->
      <div class="card filter-card fade-up">
        <div class="filter-row">
          <div class="filter-label">신고 검색</div>
          <select id="filterSearchType" class="filter-select" style="width:120px;">
            <option value="content">콘텐츠 내용</option>
            <option value="reported">작성자</option>
            <option value="reporter">신고자</option>
            <option value="reason">신고 사유</option>
          </select>
          <input type="text" id="filterKeyword" class="keyword-input" placeholder="검색어를 입력하세요" style="flex:1;">
          <button class="btn btn-primary" id="btnSearch">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
            검색
          </button>
          <button class="btn btn-ghost" id="btnReset">초기화</button>
        </div>
      </div>

      <!-- 콘텐츠 단위 테이블 -->
      <div class="card table-card fade-up" id="contentTableWrap">
        <div class="w-header" style="display:flex;justify-content:space-between;align-items:center;margin-bottom:16px;">
          <h2>신고된 콘텐츠 <span id="contentCount" style="font-size:14px;font-weight:400;color:var(--muted);"></span></h2>
        </div>
        <div class="table-wrap">
          <table>
            <thead>
              <tr>
                <th style="width:32px;"></th>
                <th>유형</th>
                <th>콘텐츠 내용</th>
                <th>작성자</th>
                <th class="sortable" id="th-reportCount">신고 횟수<span class="sort-icon"></span></th>
                <th class="sortable" id="th-userReportCount">유저 누적 신고수<span class="sort-icon"></span></th>
                <th>상태</th>
                <th class="sortable" id="th-latestReportAt">최근 신고일<span class="sort-icon"></span></th>
                <th>관리</th>
              </tr>
            </thead>
            <tbody id="contentTbody"></tbody>
          </table>
        </div>
      </div>

      <!-- 이용자별 테이블 -->
      <div class="card table-card fade-up" id="userTableWrap" style="display:none;">
        <div class="w-header" style="display:flex;justify-content:space-between;align-items:center;margin-bottom:16px;">
          <h2>이용자별 신고 현황 <span id="userCount" style="font-size:14px;font-weight:400;color:var(--muted);"></span></h2>
        </div>
        <div class="table-wrap">
          <table>
            <thead>
              <tr>
                <th style="width:32px;"></th>
                <th>작성자</th>
                <th>총 신고 건수</th>
                <th class="sortable" id="th-user-userReportCount">유저 누적 신고수<span class="sort-icon"></span></th>
                <th>회원 관리</th>
              </tr>
            </thead>
            <tbody id="userTbody"></tbody>
          </table>
        </div>
      </div>

    </main>
  </div>
</div>

<!-- 콘텐츠 전체 보기 모달 -->
<div class="modal-overlay" id="viewModal">
  <div class="view-modal-sheet">
    <div class="ms-head">
      <div>
        <h3 id="viewModalTitle">콘텐츠 전체 보기</h3>
        <p id="viewModalMeta"></p>
      </div>
      <button class="ms-close" onclick="closeViewModal()">✕</button>
    </div>
    <div class="view-modal-content">
      <div id="viewModalBody">
        <div style="text-align:center;padding:40px;color:var(--muted);">불러오는 중...</div>
      </div>
    </div>
    <div class="ms-foot">
      <button class="btn btn-ghost" onclick="closeViewModal()">닫기</button>
    </div>
  </div>
</div>

<!-- 콘텐츠 미리보기 모달 -->
<div class="modal-overlay" id="contentModal">
  <div class="modal-sheet">
    <div class="ms-head">
      <div>
        <h3 id="modalTitle">콘텐츠 상세</h3>
        <p id="modalMeta"></p>
      </div>
      <button class="ms-close" id="modalClose">✕</button>
    </div>
    <div class="ms-body">
      <div class="ms-meta" id="modalBadges"></div>
      <div class="ms-content-box" id="modalContent"></div>
    </div>
    <div class="ms-foot">
      <button class="btn btn-ghost" id="modalCancelBtn">닫기</button>
      <button class="btn-deactivate" id="modalActivateBtn"
              style="background:#059669;"
              onclick="activateContent()">활성화 처리</button>
      <button class="btn-deactivate" id="modalDeactivateBtn">비활성화 처리</button>
    </div>
  </div>
</div>

<script>
const CTX          = '${pageContext.request.contextPath}';
const CONTENT_LIST = ${contentListJson};
const USER_LIST    = ${userListJson};

const REASON_LABEL = {
  SPAM:'스팸홍보/도배글', ABUSE:'욕설/혐오', ILLEGAL:'불법정보', PORN:'음란/선정적', OTHER:'기타 부적절'
};
const TYPE_LABEL = {
  FEED:'피드', FEED_COMMENT:'피드댓글', FREEBOARD:'자유게시판',
  FREEBOARD_COMMENT:'자유게시판댓글', MATE:'동행', MATE_COMMENT:'동행댓글'
};
const CONTENT_URL = {
  FEED:      id => CTX + '/community/feed',
  FREEBOARD: id => CTX + '/community/freeboard/detail/' + id,
  MATE:      id => CTX + '/community/mate/detail/' + id
};

let currentTab = 'all';
let currentSub = '';
let sortKey = '', sortDir = -1;
let userSortKey = 'userReportCount', userSortDir = -1;

// 모달 상태
let modalTargetType = '', modalTargetId = 0, modalActive = true;

/* ── 탭 ── */
function switchTab(tab) {
  currentTab = tab; currentSub = ''; sortKey = '';
  document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
  document.getElementById('tab-' + tab).classList.add('active');
  document.querySelectorAll('.sub-tab-bar').forEach(b => b.classList.remove('visible'));
  document.querySelectorAll('.sub-tab-btn').forEach(b => b.classList.remove('active'));
  document.querySelectorAll('th.sortable').forEach(b => b.classList.remove('asc','desc'));

  const isUser = tab === 'user';
  document.getElementById('contentTableWrap').style.display = isUser ? 'none' : '';
  document.getElementById('userTableWrap').style.display    = isUser ? ''     : 'none';

  if (tab === 'freeboard') { document.getElementById('sub-freeboard').classList.add('visible'); switchSub('FREEBOARD'); return; }
  if (tab === 'feed')      { document.getElementById('sub-feed').classList.add('visible');      switchSub('FEED');      return; }
  if (tab === 'mate')      { document.getElementById('sub-mate').classList.add('visible');      switchSub('MATE');      return; }
  applyFilter();
}

function switchSub(sub) {
  currentSub = sub;
  document.querySelectorAll('.sub-tab-btn').forEach(b => b.classList.remove('active'));
  document.querySelector('.sub-tab-btn[data-sub="' + sub + '"]').classList.add('active');
  applyFilter();
}

/* ── 필터 ── */
function getContentFiltered() {
  const kw   = document.getElementById('filterKeyword').value.trim().toLowerCase();
  const type = document.getElementById('filterSearchType').value;
  return CONTENT_LIST.filter(c => {
    if (currentSub && c.targetType !== currentSub) return false;
    if (currentTab === 'freeboard' && !['FREEBOARD','FREEBOARD_COMMENT'].includes(c.targetType)) return false;
    if (currentTab === 'feed'      && !['FEED','FEED_COMMENT'].includes(c.targetType))           return false;
    if (currentTab === 'mate'      && !['MATE','MATE_COMMENT'].includes(c.targetType))           return false;
    if (!kw) return true;
    if (type === 'content'  && !(c.targetContent||'').toLowerCase().includes(kw)) return false;
    if (type === 'reported' && !(c.reportedNickname||'').toLowerCase().includes(kw)) return false;
    // 신고자/신고사유는 콘텐츠 탭에서 지원 안 됨 → 이용자별 탭으로 안내
    if (type === 'reporter' || type === 'reason') return false;
    return true;
  });
}

function getUserFiltered() {
  const kw   = document.getElementById('filterKeyword').value.trim().toLowerCase();
  const type = document.getElementById('filterSearchType').value;
  if (!kw) return USER_LIST;
  return USER_LIST.filter(r => {
    if (type === 'content'  && !(r.targetContent||'').toLowerCase().includes(kw)) return false;
    if (type === 'reported' && !(r.reportedNickname||'').toLowerCase().includes(kw)) return false;
    if (type === 'reporter' && !(r.reporterNickname||'').toLowerCase().includes(kw)) return false;
    if (type === 'reason') {
      const reasonKo = (REASON_LABEL[r.reason] || r.reason || '').toLowerCase();
      if (!reasonKo.includes(kw)) return false;
    }
    return true;
  });
}

function applyFilter() {
  const type = document.getElementById('filterSearchType').value;
  // 신고자/신고사유 검색 시 이용자별 탭으로 자동 전환
  if ((type === 'reporter' || type === 'reason') && currentTab !== 'user') {
    switchTab('user');
    return;
  }
  if (currentTab === 'user') renderUserTable(getUserFiltered());
  else                       renderContentTable(sortContentData(getContentFiltered()));
}

/* ── 정렬 ── */
function toggleSort(key) {
  if (sortKey === key) sortDir *= -1; else { sortKey = key; sortDir = -1; }
  document.querySelectorAll('#contentTableWrap th.sortable').forEach(t => t.classList.remove('asc','desc'));
  document.getElementById('th-' + key).classList.add(sortDir === -1 ? 'desc' : 'asc');
  applyFilter();
}
function sortContentData(list) {
  if (!sortKey) return list;
  return [...list].sort((a,b) => {
    const av = a[sortKey]||0, bv = b[sortKey]||0;
    return (typeof av === 'string' ? (av > bv ? 1 : -1) : (bv - av)) * (sortDir === -1 ? 1 : -1);
  });
}
function toggleUserSort(key) {
  if (userSortKey === key) userSortDir *= -1; else { userSortKey = key; userSortDir = -1; }
  document.querySelectorAll('#userTableWrap th.sortable').forEach(t => t.classList.remove('asc','desc'));
  document.getElementById('th-user-userReportCount').classList.add(userSortDir === -1 ? 'desc' : 'asc');
  applyFilter();
}

/* ── 콘텐츠 테이블 렌더 ── */
function renderContentTable(list) {
  document.getElementById('contentCount').textContent = '(' + list.length + '건)';
  const tbody = document.getElementById('contentTbody');
  if (!list.length) {
    tbody.innerHTML = '<tr><td colspan="9" style="text-align:center;padding:50px 0;color:var(--muted);">신고된 콘텐츠가 없습니다.</td></tr>';
    return;
  }
  let html = '';
  list.forEach((c, idx) => {
    const isInactive  = c.contentStatus === 0;
    const statusBadge = isInactive
      ? '<span class="badge badge-inactive">비활성</span>'
      : '<span class="badge badge-done">활성</span>';
      const cntBadge = c.totalReportCount >= 5
      ? '<span class="badge badge-danger">' + c.totalReportCount + '회 ⚠</span>'
      : '<span class="badge">' + c.totalReportCount + '회</span>';
    const userBadge   = c.userReportCount >= 10
      ? '<span class="badge badge-danger">' + c.userReportCount + '회 🚫</span>'
      : '<span class="badge">' + c.userReportCount + '회</span>';
    const authorLink  = c.reportedMemberId
      ? '<a href="' + CTX + '/admin/member/detail/' + c.reportedMemberId + '" style="color:var(--primary);font-weight:600;" onclick="event.stopPropagation()">' + esc(c.reportedNickname||'-') + '</a>'
      : (c.reportedNickname||'-');

    html += '<tr class="content-row" id="cr-' + idx + '">'
      + '<td style="text-align:center;"><span class="expand-icon">▼</span></td>'
      + '<td><span class="badge badge-type badge-' + c.targetType + '">' + (TYPE_LABEL[c.targetType]||c.targetType) + '</span></td>'
      + '<td class="content-preview">' + esc(c.targetContent||'-') + '</td>'
      + '<td>' + authorLink + '</td>'
      + '<td>' + cntBadge + '</td>'
      + '<td>' + userBadge + '</td>'
      + '<td>' + statusBadge + '</td>'
      + '<td class="num">' + (c.latestReportAt||'-') + '</td>'
      + '<td><button class="btn btn-sm btn-primary" onclick="openModal(event,' + idx + ')">상세/관리</button></td>'
      + '</tr>';

    // 아코디언: 신고자 목록 (CONTENT_LIST[idx].reports 는 없으므로 별도 fetch 또는 USER_LIST에서 필터)
    const reports = USER_LIST.filter(r => r.targetType === c.targetType && r.targetId === c.targetId);
    const detailRows = reports.length
      ? reports.map(r => '<tr>'
          + '<td>' + esc(r.reporterNickname||'-') + '</td>'
          + '<td style="font-size:12px;">' + (REASON_LABEL[r.reason]||r.reason||'-') + '</td>'
          + '<td><span class="badge badge-type badge-' + (r.status||'PENDING') + '">' + (r.status==='PENDING'?'처리대기':'처리완료') + '</span></td>'
          + '<td class="num">' + (r.createdAt||'-') + '</td>'
          + '</tr>').join('')
      : '<tr><td colspan="4" style="text-align:center;color:var(--muted);padding:12px;">신고 상세 없음</td></tr>';

    html += '<tr class="accordion-row" id="ca-' + idx + '">'
      + '<td colspan="9" style="padding:0;">'
      + '<div class="accordion-inner"><table>'
      + '<thead><tr><th>신고자</th><th>신고 사유</th><th>상태</th><th>신고일시</th></tr></thead>'
      + '<tbody>' + detailRows + '</tbody>'
      + '</table></div></td></tr>';
  });
  tbody.innerHTML = html;

  list.forEach((_, idx) => {
    document.getElementById('cr-' + idx).addEventListener('click', () => toggleContentAccordion(idx));
  });

  // 전역에 현재 필터된 list 저장 (모달용)
  window._currentContentList = list;
}

function toggleContentAccordion(idx) {
  const row = document.getElementById('cr-' + idx);
  const acc = document.getElementById('ca-' + idx);
  const open = row.classList.contains('open');
  row.classList.toggle('open', !open);
  acc.classList.toggle('open', !open);
}

/* ── 이용자별 테이블 렌더 ── */
function renderUserTable(list) {
  const userMap = {};
  list.forEach(r => {
    const uid = r.reportedMemberId || ('__' + r.reportedNickname);
    if (!userMap[uid]) userMap[uid] = { memberId: r.reportedMemberId, nickname: r.reportedNickname||'-', userReportCount: r.userReportCount||0, reports: [] };
    userMap[uid].reports.push(r);
  });
  let users = Object.values(userMap);
  users.sort((a,b) => (b[userSortKey] - a[userSortKey]) * userSortDir * -1);

  document.getElementById('userCount').textContent = '(' + users.length + '명)';
  const tbody = document.getElementById('userTbody');
  if (!users.length) {
    tbody.innerHTML = '<tr><td colspan="5" style="text-align:center;padding:50px 0;color:var(--muted);">신고 내역이 없습니다.</td></tr>';
    return;
  }
  let html = '';
  users.forEach((u, idx) => {
    const userBadge  = u.userReportCount >= 10
      ? '<span class="badge badge-danger">' + u.userReportCount + '회 🚫</span>'
      : '<span class="badge">' + u.userReportCount + '회</span>';
    const memberLink = u.memberId
      ? '<a href="' + CTX + '/admin/member/detail/' + u.memberId + '" class="btn btn-sm btn-primary" onclick="event.stopPropagation()">회원 상세</a>'
      : '-';

    html += '<tr class="user-row" id="ur-' + idx + '">'
      + '<td style="text-align:center;"><span class="expand-icon">▼</span></td>'
      + '<td><strong>' + esc(u.nickname) + '</strong></td>'
      + '<td><span class="badge">' + u.reports.length + '건</span></td>'
      + '<td>' + userBadge + '</td>'
      + '<td>' + memberLink + '</td>'
      + '</tr>';

    const detailRows = u.reports.map(r => {
      const pathFn  = CONTENT_URL[r.targetType];
      const linkBtn = '<button class="link-btn" onclick="event.stopPropagation();openViewModal(\'' + r.targetType + '\',' + r.targetId + ',\'' + esc(r.targetContent||'') + '\',\'' + esc(r.reportedNickname||'') + '\')">글 보기 →</button>';
      return '<tr>'
        + '<td><span class="badge badge-type badge-' + r.targetType + '">' + (TYPE_LABEL[r.targetType]||r.targetType) + '</span></td>'
        + '<td class="content-full">' + esc(r.targetContent||'-') + '</td>'
        + '<td>' + linkBtn + '</td>'
        + '<td>' + esc(r.reporterNickname||'-') + '</td>'
        + '<td style="font-size:12px;">' + (REASON_LABEL[r.reason]||r.reason||'-') + '</td>'
        + '<td class="num">' + (r.createdAt||'-') + '</td>'
        + '</tr>';
    }).join('');

    html += '<tr class="user-accordion-row" id="ua-' + idx + '">'
      + '<td colspan="5" style="padding:0;">'
      + '<div class="user-accordion-inner"><table>'
      + '<thead><tr><th>유형</th><th>내용</th><th>링크</th><th>신고자</th><th>신고 사유</th><th>신고일시</th></tr></thead>'
      + '<tbody>' + detailRows + '</tbody>'
      + '</table></div></td></tr>';
  });
  tbody.innerHTML = html;
  users.forEach((_, idx) => {
    document.getElementById('ur-' + idx).addEventListener('click', () => {
      const row = document.getElementById('ur-' + idx);
      const acc = document.getElementById('ua-' + idx);
      const open = row.classList.contains('open');
      row.classList.toggle('open', !open);
      acc.classList.toggle('open', !open);
    });
  });
}

/* ── 콘텐츠 전체 보기 모달 ── */
const COMMENT_PARENT_URL = {
  FREEBOARD_COMMENT: id => CTX + '/community/freeboard/detail/' + id,
  MATE_COMMENT:      id => CTX + '/community/mate/detail/' + id,
  FEED_COMMENT:      id => CTX + '/community/feed'
};

async function openViewModal(targetType, targetId, previewContent, authorNickname) {
  document.getElementById('viewModalTitle').textContent =
    (TYPE_LABEL[targetType] || targetType) + ' 전체 보기';
  document.getElementById('viewModalMeta').textContent =
    '작성자: ' + (authorNickname || '-');
  document.getElementById('viewModalBody').innerHTML =
    '<div style="text-align:center;padding:40px;color:var(--muted);">불러오는 중...</div>';
  document.getElementById('viewModal').classList.add('open');

  const isComment = ['FEED_COMMENT','FREEBOARD_COMMENT','MATE_COMMENT'].includes(targetType);

  try {
    // 모든 타입 동일하게 API 호출 (댓글 타입은 서버에서 부모 글 찾아줌)
    const res  = await fetch(CTX + '/admin/report/content?targetType=' + targetType + '&targetId=' + targetId);
    const data = await res.json();
    renderViewModal(targetType, data, isComment ? targetId : null);
  } catch(e) {
    document.getElementById('viewModalBody').innerHTML =
      '<div style="text-align:center;padding:40px;color:var(--danger);">콘텐츠를 불러오지 못했습니다.</div>';
  }
}

function renderViewModal(targetType, data, reportedCommentId, reportedCommentContent) {
  const isComment = ['FEED_COMMENT','FREEBOARD_COMMENT','MATE_COMMENT'].includes(targetType);
  let html = '';

  if (!data) {
    document.getElementById('viewModalBody').innerHTML =
      '<div style="text-align:center;padding:40px;color:var(--danger);">콘텐츠를 불러오지 못했습니다.</div>';
    return;
  }

  // 본문 표시
  html += '<div style="font-size:12px;font-weight:700;color:var(--muted);margin-bottom:8px;text-transform:uppercase;">';
  html += isComment ? '원글' : '본문 (신고됨)';
  html += '</div>';
  html += '<div class="view-post-box' + (!isComment ? ' view-comment-reported' : '') + '">'
    + esc(data.content || '(내용 없음)') + '</div>';

  // 댓글 목록
  if (data.comments && data.comments.length > 0) {
    html += '<div style="font-size:12px;font-weight:700;color:var(--muted);margin:16px 0 8px;text-transform:uppercase;">';
    html += '댓글 ' + data.comments.length + '개';
    if (isComment) html += ' <span style="font-weight:400;color:var(--danger);">(신고된 댓글 강조)</span>';
    html += '</div>';
    html += '<div style="border:1px solid var(--border);border-radius:12px;overflow:hidden;">';
    data.comments.forEach(c => {
      /* 댓글 신고일 때만 해당 댓글 강조 — commentId 일치 여부로 판단 */
      const isRep = isComment && String(c.commentId) === String(reportedCommentId);
      html += '<div class="view-comment-item' + (isRep ? ' view-comment-reported' : '') + '">'
        + '<div class="view-comment-author">' + esc(c.nickname || '-')
        + (isRep ? ' <span class="badge badge-danger" style="font-size:10px;">신고됨</span>' : '') + '</div>'
        + '<div class="view-comment-text">' + esc(c.content || '') + '</div>'
        + '</div>';
    });
    html += '</div>';
  } else {
    html += '<div style="color:var(--muted);font-size:13px;margin-top:8px;">댓글이 없습니다.</div>';
  }

  document.getElementById('viewModalBody').innerHTML = html;
}

function closeViewModal() {
  document.getElementById('viewModal').classList.remove('open');
}
function openModal(e, idx) {
  e.stopPropagation();
  const c = window._currentContentList[idx];
  modalTargetType = c.targetType;
  modalTargetId   = c.targetId;
  modalActive     = c.contentStatus !== 0;

  document.getElementById('modalTitle').textContent = (TYPE_LABEL[c.targetType]||c.targetType) + ' 상세';
  document.getElementById('modalMeta').textContent  = '작성자: ' + (c.reportedNickname||'-') + '  |  신고 ' + c.userReportCount + '회';
  document.getElementById('modalBadges').innerHTML  =
    '<span class="badge badge-type badge-' + c.targetType + '">' + (TYPE_LABEL[c.targetType]||c.targetType) + '</span> '
    + (c.contentStatus === 0 ? '<span class="badge badge-inactive">비활성</span>' : '<span class="badge badge-done">활성</span>');
  document.getElementById('modalContent').textContent = c.targetContent || '(내용 없음)';

  const deactivateBtn = document.getElementById('modalDeactivateBtn');
  const activateBtn   = document.getElementById('modalActivateBtn');

  if (c.contentStatus === 0) {
    // 비활성 상태 → 활성화 버튼만 보이기
    deactivateBtn.style.display = 'none';
    activateBtn.style.display   = '';
    activateBtn.disabled        = false;
  } else {
    // 활성 상태 → 비활성화 버튼만 보이기
    activateBtn.style.display   = 'none';
    deactivateBtn.style.display = '';
    deactivateBtn.disabled      = false;
    deactivateBtn.textContent   = '비활성화 처리';
  }

  document.getElementById('contentModal').classList.add('open');
}

function closeModal() {
  document.getElementById('contentModal').classList.remove('open');
}

async function deactivateContent() {
  if (!confirm('이 콘텐츠를 비활성화 처리하시겠습니까?')) return;
  const btn = document.getElementById('modalDeactivateBtn');
  btn.disabled = true;
  try {
    const res = await fetch(CTX + '/admin/report/deactivate', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ targetType: modalTargetType, targetId: modalTargetId })
    });
    const data = await res.json();
    if (data.success) {
      alert('비활성화 처리되었습니다.');
      closeModal();
      location.reload();
    } else {
      alert('오류: ' + (data.message||'처리 실패'));
      btn.disabled = false;
    }
  } catch(e) {
    alert('통신 오류가 발생했습니다.');
    btn.disabled = false;
  }
}

async function activateContent() {
  if (!confirm('이 콘텐츠를 다시 활성화하시겠습니까?')) return;
  const btn = document.getElementById('modalActivateBtn');
  btn.disabled = true;
  try {
    const res = await fetch(CTX + '/admin/report/activate', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ targetType: modalTargetType, targetId: modalTargetId })
    });
    const data = await res.json();
    if (data.success) {
      alert('활성화 처리되었습니다.');
      closeModal();
      location.reload();
    } else {
      alert('오류: ' + (data.message||'처리 실패'));
      btn.disabled = false;
    }
  } catch(e) {
    alert('통신 오류가 발생했습니다.');
    btn.disabled = false;
  }
}

function esc(str) {
  return String(str||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

function resetFilter() {
  document.getElementById('filterKeyword').value    = '';
  document.getElementById('filterSearchType').value = 'content';
  applyFilter();
}

/* ── 이벤트 바인딩 ── */
document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('.tab-btn').forEach(b => b.addEventListener('click', () => switchTab(b.dataset.tab)));
  document.querySelectorAll('.sub-tab-btn').forEach(b => b.addEventListener('click', () => switchSub(b.dataset.sub)));

  document.getElementById('th-reportCount').addEventListener('click',     () => toggleSort('reportCount'));
  document.getElementById('th-userReportCount').addEventListener('click', () => toggleSort('userReportCount'));
  document.getElementById('th-latestReportAt').addEventListener('click',  () => toggleSort('latestReportAt'));
  document.getElementById('th-user-userReportCount').addEventListener('click', () => toggleUserSort('userReportCount'));

  document.getElementById('filterKeyword').addEventListener('keyup', e => { if(e.key==='Enter') applyFilter(); });
  document.getElementById('btnSearch').addEventListener('click', applyFilter);
  document.getElementById('btnReset').addEventListener('click', resetFilter);

  document.getElementById('modalClose').addEventListener('click', closeModal);
  document.getElementById('modalCancelBtn').addEventListener('click', closeModal);
  document.getElementById('modalDeactivateBtn').addEventListener('click', deactivateContent);
  document.getElementById('contentModal').addEventListener('click', e => { if(e.target===e.currentTarget) closeModal(); });
  document.getElementById('viewModal').addEventListener('click', e => { if(e.target===e.currentTarget) closeViewModal(); });

  switchTab('all');
});
</script>

</body>
</html>
