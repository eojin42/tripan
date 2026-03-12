/**
 * workspace.ui.js
 * ──────────────────────────────────────────────
 * 담당: 뷰 모드 전환 · 리사이저 · 탭 · 모달 · 토스트
 *       + normalizeRow  (Oracle 대문자 키 → camelCase)
 *       + copyInviteLink (단일 정의 — ws.js·expense.js 에서 제거)
 *
 * ⚠️ 로드 순서: 가장 먼저 (다른 JS가 showToast/openModal/normalizeRow 의존)
 * ──────────────────────────────────────────────
 */

/* ══════════════════════════════
   뷰 모드 전환 (편집 / 분할 / 지도)
══════════════════════════════ */
var currentMode  = 'split';
var prevSidebarW = 520;

function setViewMode(mode) {
  if (mode === currentMode) return;

  var layout  = document.getElementById('wsLayout');
  var sidebar = document.getElementById('wsSidebar');

  if (currentMode === 'split') {
    prevSidebarW = parseInt(sidebar.style.width) || 520;
  }

  layout.classList.remove('mode-edit', 'mode-map');
  if (mode === 'edit') layout.classList.add('mode-edit');
  if (mode === 'map')  layout.classList.add('mode-map');

  if (mode === 'split') {
    requestAnimationFrame(function () { setSidebarWidth(prevSidebarW); });
  }

  // 지도 모드 진입 → 카카오맵 크기 재계산
  if (mode === 'map' && typeof triggerMapResize === 'function') {
    setTimeout(triggerMapResize, 200);
  }

  document.querySelectorAll('.view-toggle-btn').forEach(function (b) { b.classList.remove('active'); });
  var activeBtn = document.getElementById('vBtn-' + mode);
  if (activeBtn) activeBtn.classList.add('active');

  var META = {
    edit:  '📋 편집 모드 — 일정을 한눈에',
    split: '↔️ 분할 모드',
    map:   '🗺️ 지도 모드 — 동선 확인'
  };
  currentMode = mode;
  showToast(META[mode]);
}

/* 키보드 단축키: E=편집 / S=분할 / M=지도 */
document.addEventListener('keydown', function (e) {
  if (['INPUT', 'TEXTAREA', 'SELECT'].indexOf(e.target.tagName) !== -1) return;
  if (e.metaKey || e.ctrlKey || e.altKey) return;
  var k = e.key.toUpperCase();
  if (k === 'E') setViewMode('edit');
  if (k === 'S') setViewMode('split');
  if (k === 'M') setViewMode('map');
});

/* ══════════════════════════════
   사이드바 리사이저
══════════════════════════════ */
(function () {
  var sidebar = document.getElementById('wsSidebar');
  var resizer = document.getElementById('wsResizer');
  var label   = document.getElementById('sidebarWidthLabel');
  var MIN = 260, MAX = 860, DEFAULT = 520;
  var startX, startW, isDragging = false;

  var tip = document.createElement('div');
  tip.className = 'resize-tooltip';
  document.body.appendChild(tip);

  function setWidth(w) {
    w = Math.round(Math.max(MIN, Math.min(MAX, w)));
    sidebar.style.width = w + 'px';
    if (label) label.textContent = w + 'px';
    sidebar.setAttribute('data-wide', w >= 480 ? 'true' : 'false');
  }
  function showTip(x, y, w) {
    tip.textContent = Math.round(w) + 'px';
    tip.style.left  = (x + 14) + 'px';
    tip.style.top   = (y - 14) + 'px';
    tip.classList.add('show');
  }
  function hideTip() { tip.classList.remove('show'); }

  if (resizer) {
    resizer.addEventListener('mousedown', function (e) {
      e.preventDefault();
      isDragging = true;
      startX = e.clientX;
      startW = sidebar.getBoundingClientRect().width;
      resizer.classList.add('dragging');
      document.body.classList.add('resizing');
      showTip(e.clientX, e.clientY, startW);
    });
  }
  document.addEventListener('mousemove', function (e) {
    if (!isDragging) return;
    var w = startW + (e.clientX - startX);
    setWidth(w);
    showTip(e.clientX, e.clientY, w);
  });
  document.addEventListener('mouseup', function () {
    if (!isDragging) return;
    isDragging = false;
    if (resizer) resizer.classList.remove('dragging');
    document.body.classList.remove('resizing');
    hideTip();
    showToast('↔ ' + Math.round(sidebar.getBoundingClientRect().width) + 'px 로 조절됨');
  });
  if (resizer) {
    resizer.addEventListener('dblclick', function () {
      sidebar.style.transition = 'width .3s cubic-bezier(.19,1,.22,1)';
      setWidth(DEFAULT);
      setTimeout(function () { sidebar.style.transition = ''; }, 320);
      showToast('↔ 기본 너비로 초기화됨');
    });
  }

  window.setSidebarWidth = function (w) {
    sidebar.style.transition = 'width .28s cubic-bezier(.19,1,.22,1)';
    setWidth(w);
    setTimeout(function () { sidebar.style.transition = ''; }, 300);
  };

  setWidth(DEFAULT);
})();

/* ══════════════════════════════
   편집모드 추천 패널 리사이저
══════════════════════════════ */
(function () {
  var panel   = document.getElementById('editRecommendPanel');
  var resizer = document.getElementById('editRpResizer');
  if (!resizer) return;
  var MIN = 200, MAX = 560, DEFAULT = 380;
  var startX, startW, isDragging = false;

  var tip = document.createElement('div');
  tip.className = 'resize-tooltip';
  document.body.appendChild(tip);

  function setW(w) {
    w = Math.round(Math.max(MIN, Math.min(MAX, w)));
    panel.style.width = w + 'px';
  }
  function showTip(x, y, w) {
    tip.textContent = Math.round(w) + 'px';
    tip.style.left  = (x + 14) + 'px';
    tip.style.top   = (y - 14) + 'px';
    tip.classList.add('show');
  }
  function hideTip() { tip.classList.remove('show'); }

  resizer.addEventListener('mousedown', function (e) {
    e.preventDefault();
    isDragging = true;
    startX = e.clientX;
    startW = panel.getBoundingClientRect().width;
    resizer.classList.add('dragging');
    document.body.classList.add('resizing');
    showTip(e.clientX, e.clientY, startW);
  });
  document.addEventListener('mousemove', function (e) {
    if (!isDragging) return;
    var w = startW + (e.clientX - startX);
    setW(w);
    showTip(e.clientX, e.clientY, w);
  });
  document.addEventListener('mouseup', function () {
    if (!isDragging) return;
    isDragging = false;
    resizer.classList.remove('dragging');
    document.body.classList.remove('resizing');
    hideTip();
  });
  resizer.addEventListener('dblclick', function () {
    panel.style.transition = 'width .3s cubic-bezier(.19,1,.22,1)';
    setW(DEFAULT);
    setTimeout(function () { panel.style.transition = ''; }, 320);
  });
})();

/* ══════════════════════════════
   탭 전환
══════════════════════════════ */
function switchPanel(name, btn) {
  document.querySelectorAll('.sidebar-panel').forEach(function (p) { p.classList.remove('active'); });
  document.querySelectorAll('.ws-tab').forEach(function (t) { t.classList.remove('active'); });
  var panel = document.getElementById('panel-' + name);
  if (panel) panel.classList.add('active');
  if (btn) btn.classList.add('active');
}

/* ══════════════════════════════
   모달
══════════════════════════════ */
function openModal(id) {
  var el = document.getElementById(id);
  if (el) el.classList.add('open');
}
function closeModal(id) {
  var el = document.getElementById(id);
  if (el) el.classList.remove('open');
}
document.querySelectorAll('.modal-overlay').forEach(function (el) {
  el.addEventListener('click', function (e) {
    if (e.target === this) this.classList.remove('open');
  });
});

/* ══════════════════════════════
   토스트 (하단 스택)
══════════════════════════════ */
function showToast(msg) {
  var wrap = document.getElementById('toastWrap');
  if (!wrap) return;
  var t = document.createElement('div');
  t.className   = 'toast';
  t.textContent = msg;
  wrap.appendChild(t);
  setTimeout(function () {
    t.style.transition = 'opacity .3s, transform .3s';
    t.style.opacity    = '0';
    t.style.transform  = 'translateY(10px)';
    setTimeout(function () { t.remove(); }, 300);
  }, 2200);
}

/* ══════════════════════════════
   초대 링크 복사
   ← ws.js·expense.js 에서 중복 정의 제거 후 여기서만 관리
══════════════════════════════ */
function copyInviteLink() {
  var el = document.getElementById('inviteLinkText');
  if (!el) return;
  var link = el.innerText || el.textContent || '';
  if (navigator.clipboard) {
    navigator.clipboard.writeText(link)
      .then(function () { showToast('🔗 초대 링크가 복사됐어요!'); })
      .catch(function () { _fallbackCopy(link); });
  } else {
    _fallbackCopy(link);
  }
}
function _fallbackCopy(text) {
  var ta = document.createElement('textarea');
  ta.value = text;
  document.body.appendChild(ta);
  ta.select();
  document.execCommand('copy');
  document.body.removeChild(ta);
  showToast('🔗 초대 링크가 복사됐어요!');
}

/* ══════════════════════════════
   Oracle 대문자 키 → camelCase 정규화
   ← JSP 인라인에서 이동. checklist/vote/notif/expense 전부 사용.
══════════════════════════════ */
function normalizeRow(row) {
  if (!row || typeof row !== 'object') return row;
  var known = {
    /* 체크리스트 */
    'checklistid':'checklistId', 'tripid':'tripId',       'itemname':'itemName',
    'ischecked':'isChecked',     'checkmanager':'checkManager',
    /* 투표 */
    'voteid':'voteId',           'candidateid':'candidateId',
    'candidatename':'candidateName', 'votecount':'voteCount', 'totalvotes':'totalVotes',
    /* 알림 */
    'notificationid':'notificationId', 'receiverid':'receiverId', 'senderid':'senderId',
    'isread':'isRead',           'createdat':'createdAt',  'timeago':'timeAgo',
    /* 지출 */
    'expenseid':'expenseId',     'payerid':'payerId',      'expensedate':'expenseDate',
    'isprivate':'isPrivate',     'payernickname':'payerNickname',
    /* 공통 */
    'title':'title', 'message':'message', 'type':'type', 'category':'category',
    'amount':'amount', 'description':'description', 'status':'status'
  };
  var out = {};
  Object.keys(row).forEach(function (k) {
    var mapped = known[k.toLowerCase()];
    out[mapped || k] = row[k];
  });
  return out;
}
