/**
 * workspace.ui.js
 * 뷰 모드 전환 · 리사이저 · 탭 · 모달 · 토스트
 * 로드 순서: workspace.jsp 하단 <script> 참고
 */

var currentMode = 'split';
var prevSidebarW = 520;

function setViewMode(mode) {
  if (mode === currentMode) return;

  var layout  = document.getElementById('wsLayout');
  var sidebar = document.getElementById('wsSidebar');

  /* 분할 모드에서 나갈 때 너비 저장 */
  if (currentMode === 'split') {
    prevSidebarW = parseInt(sidebar.style.width) || 520;
  }

  /* 레이아웃 클래스 교체 */
  layout.classList.remove('mode-edit', 'mode-map');
  if (mode === 'edit') layout.classList.add('mode-edit');
  if (mode === 'map')  layout.classList.add('mode-map');

  /* 분할로 돌아올 때 너비 복원 */
  if (mode === 'split') {
    requestAnimationFrame(function(){ setSidebarWidth(prevSidebarW); });
  }

  /* 버튼 active */
  document.querySelectorAll('.view-toggle-btn').forEach(function(b){ b.classList.remove('active'); });
  document.getElementById('vBtn-' + mode).classList.add('active');

  var META = {
    edit:  { toast: '📋 편집 모드 — 일정을 한눈에' },
    split: { toast: '↔️ 분할 모드' },
    map:   { toast: '🗺️ 지도 모드 — 동선 확인' }
  };

  currentMode = mode;
  showToast(META[mode].toast);
}

/* 키보드 단축키: E=편집 / S=분할 / M=지도 */
document.addEventListener('keydown', function(e) {
  if (['INPUT','TEXTAREA','SELECT'].indexOf(e.target.tagName) !== -1) return;
  if (e.metaKey || e.ctrlKey || e.altKey) return;
  var k = e.key.toUpperCase();
  if (k === 'E') setViewMode('edit');
  if (k === 'S') setViewMode('split');
  if (k === 'M') setViewMode('map');
});

/* ══════════════════════════════
   사이드바 리사이저
══════════════════════════════ */
(function(){
  var sidebar  = document.getElementById('wsSidebar');
  var resizer  = document.getElementById('wsResizer');
  var label    = document.getElementById('sidebarWidthLabel');
  var MIN = 260, MAX = 860, DEFAULT = 520;
  var startX, startW, isDragging = false;

  // 툴팁
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
    tip.style.left = (x + 14) + 'px';
    tip.style.top  = (y - 14) + 'px';
    tip.classList.add('show');
  }
  function hideTip() { tip.classList.remove('show'); }

  resizer.addEventListener('mousedown', function(e) {
    e.preventDefault();
    isDragging = true;
    startX = e.clientX;
    startW = sidebar.getBoundingClientRect().width;
    resizer.classList.add('dragging');
    document.body.classList.add('resizing');
    showTip(e.clientX, e.clientY, startW);
  });

  document.addEventListener('mousemove', function(e) {
    if (!isDragging) return;
    var w = startW + (e.clientX - startX);
    setWidth(w);
    showTip(e.clientX, e.clientY, w);
  });

  document.addEventListener('mouseup', function() {
    if (!isDragging) return;
    isDragging = false;
    resizer.classList.remove('dragging');
    document.body.classList.remove('resizing');
    hideTip();
    var w = sidebar.getBoundingClientRect().width;
    showToast('↔ ' + Math.round(w) + 'px 로 조절됨');
  });

  // 더블클릭 → 기본값 복귀
  resizer.addEventListener('dblclick', function() {
    sidebar.style.transition = 'width .3s cubic-bezier(.19,1,.22,1)';
    setWidth(DEFAULT);
    setTimeout(function(){ sidebar.style.transition = ''; }, 320);
    showToast('↔ 기본 너비로 초기화됨');
  });

  // 버튼 프리셋
  window.setSidebarWidth = function(w) {
    sidebar.style.transition = 'width .28s cubic-bezier(.19,1,.22,1)';
    setWidth(w);
    setTimeout(function(){ sidebar.style.transition = ''; }, 300);
  };

  // 초기값 520px
  setWidth(DEFAULT);
})();

/* ══════════════════════════════
   편집모드 추천 패널 리사이저
══════════════════════════════ */
(function(){
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
    tip.style.left = (x + 14) + 'px';
    tip.style.top  = (y - 14) + 'px';
    tip.classList.add('show');
  }
  function hideTip() { tip.classList.remove('show'); }

  resizer.addEventListener('mousedown', function(e) {
    e.preventDefault();
    isDragging = true;
    startX = e.clientX;
    startW = panel.getBoundingClientRect().width;
    resizer.classList.add('dragging');
    document.body.classList.add('resizing');
    showTip(e.clientX, e.clientY, startW);
  });
  document.addEventListener('mousemove', function(e) {
    if (!isDragging) return;
    var w = startW + (e.clientX - startX);
    setW(w);
    showTip(e.clientX, e.clientY, w);
  });
  document.addEventListener('mouseup', function() {
    if (!isDragging) return;
    isDragging = false;
    resizer.classList.remove('dragging');
    document.body.classList.remove('resizing');
    hideTip();
  });
  resizer.addEventListener('dblclick', function() {
    panel.style.transition = 'width .3s cubic-bezier(.19,1,.22,1)';
    setW(DEFAULT);
    setTimeout(function(){ panel.style.transition = ''; }, 320);
  });
})();

/* ══════════════════════════════
   탭 전환
══════════════════════════════ */
function switchPanel(name, btn) {
  document.querySelectorAll('.sidebar-panel').forEach(function(p){ p.classList.remove('active'); });
  document.querySelectorAll('.ws-tab').forEach(function(t){ t.classList.remove('active'); });
  document.getElementById('panel-' + name).classList.add('active');
  btn.classList.add('active');
}

/* ══════════════════════════════
   모달
══════════════════════════════ */
function openModal(id) {
  document.getElementById(id).classList.add('open');
}
function closeModal(id) {
  document.getElementById(id).classList.remove('open');
}
document.querySelectorAll('.modal-overlay').forEach(function(el) {
  el.addEventListener('click', function(e) {
    if (e.target === this) this.classList.remove('open');
  });
});

/* ══════════════════════════════

   토스트
══════════════════════════════ */
function showToast(msg) {
  var wrap = document.getElementById('toastWrap');
  var t = document.createElement('div');
  t.className = 'toast';
  t.textContent = msg;
  wrap.appendChild(t);
  setTimeout(function() {
    t.style.transition = 'opacity .3s, transform .3s';
    t.style.opacity = '0';
    t.style.transform = 'translateY(10px)';
    setTimeout(function() { t.remove(); }, 300);
  }, 2200);
}

