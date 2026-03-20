/**
 * workspace_expense.js — 전면 개편
 * ──────────────────────────────────────────────────────────
 * 담당: 가계부 · 정산 CRUD + 내부 3탭 (홈 / 내역 / 정산)
 * 의존: workspace.ui.js (showToast, openModal, closeModal, normalizeRow)
 *       TRIP_ID, CTX_PATH, MY_MEMBER_ID, MEMBER_DICT
 *
 * ★ 개편 사항:
 *   [홈] 대시보드 + 정산 요청 건수 재정의 + 카테고리 카드 UI + 내 지출 요약
 *   [내역] 카테고리 UI 통일 + 지출 상세 모달 개선 (영수증 이미지)
 *   [정산] P2P 워크플로우 (받을 정산 / 줘야 할 정산 / 완료 내역)
 * ──────────────────────────────────────────────────────────
 */

/* ═══════════════════════════════════════════
   카테고리 메타데이터
═══════════════════════════════════════════ */
var _CAT_META = {
  FOOD:          { icon: '🍽️', name: '식비',   color: '#FF6B6B', bg: 'linear-gradient(135deg,#FF6B6B,#FFB4B4)', light: 'rgba(255,107,107,.12)' },
  ACCOMMODATION: { icon: '🏨', name: '숙소',   color: '#4ECDC4', bg: 'linear-gradient(135deg,#4ECDC4,#A8E6CF)', light: 'rgba(78,205,196,.12)' },
  TRANSPORT:     { icon: '🚗', name: '교통',   color: '#7C5CFC', bg: 'linear-gradient(135deg,#7C5CFC,#B8A9FC)', light: 'rgba(124,92,252,.12)' },
  TOUR:          { icon: '🎯', name: '관광',   color: '#3B82F6', bg: 'linear-gradient(135deg,#3B82F6,#93C5FD)', light: 'rgba(59,130,246,.12)' },
  CAFE:          { icon: '☕', name: '카페',   color: '#F59E0B', bg: 'linear-gradient(135deg,#F59E0B,#FCD34D)', light: 'rgba(245,158,11,.12)' },
  SHOPPING:      { icon: '🛍️', name: '쇼핑',  color: '#10B981', bg: 'linear-gradient(135deg,#10B981,#6EE7B7)', light: 'rgba(16,185,129,.12)' },
  ETC:           { icon: '📦', name: '기타',   color: '#94A3B8', bg: 'linear-gradient(135deg,#94A3B8,#CBD5E1)', light: 'rgba(148,163,184,.12)' }
};
var _CAT_ORDER = ['FOOD', 'TRANSPORT', 'ACCOMMODATION', 'TOUR', 'CAFE', 'SHOPPING', 'ETC'];
function _cat(k) { return _CAT_META[(k||'ETC').toUpperCase()] || _CAT_META.ETC; }
function _esc(str) { return String(str).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function _getMyMid() {
  var v = (typeof MY_MEMBER_ID!=='undefined') ? MY_MEMBER_ID : (typeof LOGIN_MEMBER_ID!=='undefined') ? LOGIN_MEMBER_ID : null;
  var n = Number(v); return (!isNaN(n) && n > 0) ? n : null;
}
function _fmtAmt(v) { return '₩ ' + Number(v||0).toLocaleString(); }

/* ═══════════════════════════════════════════
   내부 탭 전환
═══════════════════════════════════════════ */
function switchExpTab(name, btn) {
  document.querySelectorAll('.exp-tab-pane').forEach(function(p) { p.style.display = 'none'; });
  document.querySelectorAll('.exp-itab').forEach(function(b) {
    b.style.color = 'var(--light)'; b.style.borderBottom = '2px solid transparent';
    b.style.fontWeight = '700'; b.style.backgroundColor = 'transparent';
  });
  var pane = document.getElementById('exp-tab-' + name);
  if (pane) { pane.style.display = 'flex'; pane.style.flexDirection = 'column'; }
  if (btn) { btn.style.color = '#2D3748'; btn.style.borderBottom = '2.5px solid #89CFF0'; btn.style.fontWeight = '800'; }
  if (name === 'home')   _loadHomeTab();
  if (name === 'list')   loadExpenseList();
  if (name === 'settle') _loadSettleTab();
}


/* ═══════════════════════════════════════════════════════
   ①  홈 탭 — 대시보드 (전면 개편)
   GET /api/trips/{tripId}/expenses/summary
═══════════════════════════════════════════════════════ */
function _loadHomeTab() {
  var myMid = _getMyMid() || 0;

  fetch(CTX_PATH + '/api/trips/' + TRIP_ID + '/expenses/summary')
    .then(function(r) { return r.ok ? r.json() : Promise.reject(r.status); })
    .then(function(data) {
      var total = Number(data.totalAmount || 0);
      _setText('summaryAmt', _fmtAmt(total));

      /* ── 나의 결제 / 부담 ── */
      var myPaid = 0, myShare = 0, myBal = 0;
      (data.memberPayments||[]).forEach(function(p) { if (Number(p.memberId)===myMid) myPaid = Number(p.paidAmount||0); });
      var myEntry = null;
      (data.memberShares||[]).forEach(function(s) { if (Number(s.memberId)===myMid) { myShare = Number(s.shareAmount||0); myBal = Number(s.balance||0); myEntry = s; } });

      _setText('myPaidAmt',  _fmtAmt(myPaid));
      _setText('myShareAmt', _fmtAmt(myShare));

      /* ── 받을/보낼 예정 금액 ── */
      var recvEl = document.getElementById('myReceiveAmt');
      var sendEl = document.getElementById('mySendAmt');
      if (recvEl) recvEl.textContent = myBal > 0 ? _fmtAmt(myBal) : '₩ 0';
      if (sendEl) sendEl.textContent = myBal < 0 ? _fmtAmt(Math.abs(myBal)) : '₩ 0';

      /* ── 나의 잔액 상태 ── */
      var myBalEl = document.getElementById('myBalanceLine');
      if (myBalEl) {
        if (myBal > 0) myBalEl.innerHTML = '<span class="exp-home-balance-chip exp-home-balance-chip--recv">💚 ' + _fmtAmt(myBal) + ' 받을 예정</span>';
        else if (myBal < 0) myBalEl.innerHTML = '<span class="exp-home-balance-chip exp-home-balance-chip--send">💸 ' + _fmtAmt(Math.abs(myBal)) + ' 보낼 예정</span>';
        else myBalEl.innerHTML = '<span class="exp-home-balance-chip exp-home-balance-chip--done">✅ 정산 없음</span>';
      }

      /* ── 정산 대기 현황 (수정 요구사항 1: 나에게 온 정산 요청 건수) ── */
      _renderSettleStatusChip();

      /* ── 카테고리별 지출 (수정 요구사항 2: 가로 스크롤 카드) ── */
      _renderCategoryCards(data.categoryBreakdown || [], total);

      /* ── 내 지출 요약 (수정 요구사항 3) ── */
      _renderMyExpenseSummaryV2(myPaid, myShare, myBal, data.categoryBreakdown || [], data.memberShares || [], myMid);
    })
    .catch(function(err) { console.warn('[Expense] 홈 탭 로드 실패:', err); });
}

function _setText(id, txt) { var el = document.getElementById(id); if (el) el.textContent = txt; }


/* ─── 정산 대기 현황 칩 (수정 요구사항 1) ─── */
/* 정산 요청 건수 = "상대방이 나에게 정산 요청을 보낸 건수"
   → settlement 테이블에서 from_member_id = 나 AND status = REQUESTED|PENDING
   (내가 debtor이고, creditor가 요청한 건)                                    */
function _renderSettleStatusChip() {
  var el = document.getElementById('expSettleStatus');
  if (!el) return;
  var myMid = _getMyMid(); if (!myMid) { el.innerHTML=''; return; }

  fetch(CTX_PATH + '/api/trips/' + TRIP_ID + '/settlements?memberId=' + myMid)
    .then(function(r) { return r.ok ? r.json() : null; })
    .then(function(data) {
      var list = data && data.settlements ? data.settlements : [];
      /* 나에게 온 정산 요청 = fromMemberId = 나 (내가 돈 보내야 함) + REQUESTED/PENDING */
      var incoming = list.filter(function(s) {
        return (s.status === 'REQUESTED' || s.status === 'PENDING')
          && Number(s.fromMemberId) === myMid;
      });
      if (!incoming.length) { el.innerHTML = ''; return; }
      var totalAmt = incoming.reduce(function(sum, s) { return sum + Number(s.amount || 0); }, 0);
      el.innerHTML = '<div class="exp-home-settle-chip" onclick="switchExpTab(\'settle\', document.querySelectorAll(\'.exp-itab\')[2])">'
        + '<div class="exp-home-settle-chip__left">'
        +   '<div class="exp-home-settle-chip__icon">📬</div>'
        +   '<div>'
        +     '<div class="exp-home-settle-chip__title">처리 대기 중인 정산 요청</div>'
        +     '<div class="exp-home-settle-chip__sub">총 ' + _fmtAmt(totalAmt) + ' · 정산 탭에서 확인하세요</div>'
        +   '</div>'
        + '</div>'
        + '<span class="exp-home-settle-chip__badge">' + incoming.length + '건</span>'
        + '</div>';
    })
    .catch(function() { el.innerHTML = ''; });
}


/* ─── 카테고리별 지출 카드 (수정 요구사항 2) ─── */
/* 가로 스크롤, 카드형, 컬러풀 */
function _renderCategoryCards(breakdown, total) {
  var section = document.getElementById('expenseCatsSection');
  var wrap    = document.getElementById('expenseCats');
  if (!wrap) return;

  var filtered = (breakdown||[]).filter(function(c) { return Number(c.totalAmount||0)>0; });
  if (!filtered.length) { if (section) section.style.display='none'; return; }
  if (section) section.style.display='';

  /* _CAT_ORDER 순서 정렬 */
  var ordered = _CAT_ORDER
    .map(function(k) { return filtered.find(function(c) { return (c.category||'').toUpperCase()===k; }); })
    .filter(Boolean);
  filtered.forEach(function(c) {
    var k = (c.category||'ETC').toUpperCase();
    if (_CAT_ORDER.indexOf(k)===-1) ordered.push(c);
  });

  wrap.innerHTML = ordered.map(function(c) {
    var k   = (c.category||'ETC').toUpperCase();
    var m   = _cat(k);
    var amt = Number(c.totalAmount||0);
    var pct = total > 0 ? Math.round(amt/total*100) : 0;
    return '<div class="exp-cat-card" onclick="openCatDetail(\'' + k + '\')" style="--cat-color:' + m.color + ';--cat-bg:' + m.bg + ';--cat-light:' + m.light + ';">'
      + '<div class="exp-cat-card__header">'
      +   '<div class="exp-cat-card__icon-wrap"><span class="exp-cat-card__icon">' + m.icon + '</span></div>'
      +   '<span class="exp-cat-card__pct">' + pct + '%</span>'
      + '</div>'
      + '<div class="exp-cat-card__name">' + m.name + '</div>'
      + '<div class="exp-cat-card__amt">' + _fmtAmt(amt) + '</div>'
      + '<div class="exp-cat-card__bar"><div class="exp-cat-card__bar-fill" style="width:' + pct + '%;"></div></div>'
      + '</div>';
  }).join('');
}


/* ─── 내 지출 요약 (수정 요구사항 3 — "나" 중심, 결제/부담 중복 제거) ─── */
function _renderMyExpenseSummaryV2(myPaid, myShare, myBal, categoryBreakdown, memberShares, myMid) {
  var el = document.getElementById('expMySummarySection');
  if (!el) return;
  if (!myMid || (myPaid === 0 && myShare === 0)) { el.style.display='none'; return; }
  el.style.display = '';

  var balHtml, balClass;
  if (myBal > 0) { balHtml = '💚 ' + _fmtAmt(myBal) + ' 받을 예정'; balClass = 'recv'; }
  else if (myBal < 0) { balHtml = '💸 ' + _fmtAmt(Math.abs(myBal)) + ' 보낼 예정'; balClass = 'send'; }
  else { balHtml = '✅ 정산 없음'; balClass = 'done'; }

  /* 상단 히어로에 결제/부담이 이미 있으므로 여기선 정산 결과 + 카테고리 분석만 */
  var summaryBody = document.getElementById('expMySummaryBody');
  summaryBody.innerHTML =
      '<div class="my-summary-result my-summary-result--' + balClass + '">' + balHtml + '</div>'
    + '<div id="myCatBreakdown" class="my-cat-breakdown"></div>'
    + '<div id="myRecentExpense" class="my-recent-expense"></div>'
    + '<button class="exp-my-detail-btn" onclick="openMyExpenseDetail()">내 지출 상세 보기 →</button>';

  /* 내 카테고리별 지출 조회 (expenses 목록 기반) */
  fetch(CTX_PATH + '/api/trips/' + TRIP_ID + '/expenses?page=1&size=200')
    .then(function(r) { return r.ok ? r.json() : []; })
    .then(function(list) {
      list = (list||[]).map(normalizeRow);
      var myExpenses = list.filter(function(e) { return Number(e.payerId) === myMid; });

      /* 내 카테고리 분석 */
      var catMap = {};
      myExpenses.forEach(function(e) {
        var k = (e.category||'ETC').toUpperCase();
        if (!catMap[k]) catMap[k] = 0;
        catMap[k] += Number(e.amount||0);
      });

      var catEntries = Object.keys(catMap).map(function(k) { return { cat: k, amt: catMap[k] }; })
        .sort(function(a,b) { return b.amt - a.amt; });

      if (catEntries.length) {
        var catHtml = '<div class="my-cat-bd__title">내가 가장 많이 쓴 카테고리</div>';
        catHtml += catEntries.map(function(c, i) {
          var m = _cat(c.cat);
          var maxAmt = catEntries[0].amt || 1;
          var barW = Math.round(c.amt / maxAmt * 100);
          return '<div class="my-cat-bd__row">'
            + '<div class="my-cat-bd__left">'
            +   '<span class="my-cat-bd__rank">' + (i+1) + '</span>'
            +   '<span class="my-cat-bd__icon" style="background:' + m.light + ';">' + m.icon + '</span>'
            +   '<span class="my-cat-bd__name">' + m.name + '</span>'
            + '</div>'
            + '<div class="my-cat-bd__right">'
            +   '<div class="my-cat-bd__bar"><div class="my-cat-bd__bar-fill" style="width:' + barW + '%;background:' + m.color + ';"></div></div>'
            +   '<span class="my-cat-bd__amt">' + _fmtAmt(c.amt) + '</span>'
            + '</div>'
            + '</div>';
        }).join('');
        var catEl = document.getElementById('myCatBreakdown');
        if (catEl) catEl.innerHTML = catHtml;
      }

      /* 최근 결제 지출 (최대 3건) */
      var recent = myExpenses.sort(function(a,b) {
        return String(b.expenseDate||'').localeCompare(String(a.expenseDate||''));
      }).slice(0,3);

      if (recent.length) {
        var recentHtml = '<div class="my-cat-bd__title" style="margin-top:16px;">최근 내가 결제한 지출</div>';
        recentHtml += recent.map(function(e) {
          var m = _cat(e.category);
          var date = e.expenseDate ? String(e.expenseDate).substring(5).replace(/-/g,'/') : '';
          return '<div class="my-recent-item" onclick="openExpenseDetail(' + e.expenseId + ')">'
            + '<div class="my-recent-item__icon" style="background:' + m.light + ';">' + m.icon + '</div>'
            + '<div class="my-recent-item__info">'
            +   '<div class="my-recent-item__name">' + _esc(e.description||'') + '</div>'
            +   '<div class="my-recent-item__meta">' + date + ' · ' + m.name + '</div>'
            + '</div>'
            + '<div class="my-recent-item__amt">' + _fmtAmt(e.amount) + '</div>'
            + '</div>';
        }).join('');
        var recentEl = document.getElementById('myRecentExpense');
        if (recentEl) recentEl.innerHTML = recentHtml;
      }
    }).catch(function() {});
}


/* ═══════════════════════════════════════════════════════
   ②  내역 탭 — 지출 목록 (카테고리 UI 개선)
   GET /api/trips/{tripId}/expenses?page=1&size=50
═══════════════════════════════════════════════════════ */
function loadExpenseList() {
  var listEl = document.getElementById('expenseList');
  if (!listEl) return;
  listEl.innerHTML = '<div class="expense-empty-state"><div class="expense-empty-state__icon">⏳</div>'
    + '<div class="expense-empty-state__title">불러오는 중...</div></div>';

  fetch(CTX_PATH + '/api/trips/' + TRIP_ID + '/expenses?page=1&size=50')
    .then(function(r) { return r.ok ? r.json() : Promise.reject(r.status); })
    .then(function(list) {
      list = (list||[]).map(normalizeRow);
      var cntEl = document.getElementById('expenseCount');
      if (cntEl) cntEl.textContent = list.length ? '총 ' + list.length + '건' : '';

      if (!list.length) {
        listEl.innerHTML = '<div class="expense-empty-state">'
          + '<div class="expense-empty-state__emoji">🧾</div>'
          + '<div class="expense-empty-state__title">아직 등록된 지출이 없어요</div>'
          + '<div class="expense-empty-state__sub">첫 지출을 추가해 여행 가계부를 시작해보세요</div>'
          + '<button class="expense-empty-state__btn" onclick="openModal(\'addExpenseModal\')">지출 추가하기</button>'
          + '</div>';
        return;
      }

      /* 날짜순 정렬 (최신순) */
      list.sort(function(a,b) {
        return String(b.expenseDate||'').localeCompare(String(a.expenseDate||''));
      });

      /* 날짜별 그룹핑 */
      var grouped = {}, dateOrder = [];
      list.forEach(function(e) {
        var d = e.expenseDate ? String(e.expenseDate).substring(0,10) : '날짜 없음';
        if (!grouped[d]) { grouped[d] = []; dateOrder.push(d); }
        grouped[d].push(e);
      });

      var html = '';
      dateOrder.forEach(function(d) {
        var label = d !== '날짜 없음' ? d.substring(5).replace(/-/g,'/') : '날짜 없음';
        var dayTotal = grouped[d].reduce(function(s,e) { return s + Number(e.amount||0); }, 0);
        html += '<div class="exp-list-date-group">'
          + '<div class="exp-list-date-header">'
          +   '<div class="exp-list-date-label">' + label + '</div>'
          +   '<div class="exp-list-date-total">' + _fmtAmt(dayTotal) + '</div>'
          + '</div>';

        grouped[d].forEach(function(e) {
          var m = _cat(e.category);
          var hasMemo    = !!(e.memo && String(e.memo).trim());
          var hasReceipt = !!(e.receiptUrl && String(e.receiptUrl).trim());
          html += '<div class="expense-item" onclick="openExpenseDetail(' + e.expenseId + ')">'
            /* 카테고리 아이콘 — 통일된 색상 체계 */
            + '<div class="expense-item__cat-icon" style="background:' + m.light + ';color:' + m.color + ';">' + m.icon + '</div>'
            + '<div class="expense-item__info">'
            +   '<div class="expense-item__name">' + _esc(e.description||'') + '</div>'
            +   '<div class="expense-item__meta">'
            +     '<span class="expense-item__cat-badge" style="background:' + m.light + ';color:' + m.color + ';">' + m.name + '</span>'
            +     '<span class="expense-item__payer">👤 ' + _esc(e.payerNickname||'?') + '</span>'
            +     (hasMemo ? '<span class="expense-extra-badge">📝</span>' : '')
            +     (hasReceipt ? '<span class="expense-extra-badge expense-extra-badge--img">📷</span>' : '')
            +   '</div>'
            + '</div>'
            + '<div class="expense-item__right">'
            +   '<div class="expense-item__amt">' + _fmtAmt(e.amount) + '</div>'
            +   '<button class="expense-del-btn" onclick="event.stopPropagation();deleteExpenseItem(' + e.expenseId + ')" title="삭제">✕</button>'
            + '</div>'
            + '</div>';
        });
        html += '</div>';
      });
      listEl.innerHTML = html;
    })
    .catch(function(err) {
      console.warn('[Expense] 목록 로드 실패:', err);
      listEl.innerHTML = '<div class="expense-empty-state">'
        + '<div class="expense-empty-state__emoji">🧾</div>'
        + '<div class="expense-empty-state__title">아직 등록된 지출이 없어요</div>'
        + '<div class="expense-empty-state__sub">첫 지출을 추가해 여행 가계부를 시작해보세요</div>'
        + '<button class="expense-empty-state__btn" onclick="openModal(\'addExpenseModal\')">지출 추가하기</button>'
        + '</div>';
    });
}


/* ═══════════════════════════════════════════════════════
   ③  정산 탭 — P2P 워크플로우 (전면 재설계)
   - 내가 받을 정산 / 내가 줘야 할 정산 / 완료 내역
   - 정산 현황 ↔ 완료 내역 토글 (강조 버튼)
═══════════════════════════════════════════════════════ */
var _settleView = 'status'; /* 'status' | 'done' */

function _loadSettleTab() {
  _settleView = 'status';
  _renderSettleView();
}

function switchSettleView(view) {
  _settleView = view;
  _renderSettleView();
}

function _renderSettleView() {
  var statusSection = document.getElementById('settleStatusView');
  var doneSection   = document.getElementById('settleDoneView');
  var btnStatus     = document.getElementById('settleBtnStatus');
  var btnDone       = document.getElementById('settleBtnDone');

  if (_settleView === 'status') {
    if (statusSection) statusSection.style.display = '';
    if (doneSection)   doneSection.style.display   = 'none';
    if (btnStatus) { btnStatus.classList.add('active'); }
    if (btnDone)   { btnDone.classList.remove('active'); }
    _loadSettleStatusView();
  } else {
    if (statusSection) statusSection.style.display = 'none';
    if (doneSection)   doneSection.style.display   = '';
    if (btnStatus) { btnStatus.classList.remove('active'); }
    if (btnDone)   { btnDone.classList.add('active'); }
    _loadSettleDoneView();
  }
}

/* 정산 현황 뷰 — 지출건별 P2P + 같은 총대 묶음 합산 */
function _loadSettleStatusView() {
  var recvList  = document.getElementById('settleRecvList');
  var sendList  = document.getElementById('settleSendList');
  var emptyEl   = document.getElementById('settleStatusEmpty');
  var myMid     = _getMyMid();

  if (!myMid) {
    if (recvList) recvList.innerHTML = '<div class="settle-empty-msg">로그인 정보를 확인해주세요</div>';
    return;
  }

  [recvList, sendList].forEach(function(el) { if (el) el.innerHTML = '<div class="settle-loading">불러오는 중...</div>'; });
  if (emptyEl) emptyEl.style.display = 'none';

  /* 두 API 동시 호출:
     1) 지출+참여자 전체 → P2P 정산 계산
     2) 기존 settlement → 요청/완료 상태 매핑 */
  var expUrl    = CTX_PATH + '/api/trips/' + TRIP_ID + '/expenses/with-participants';
  var settleUrl = CTX_PATH + '/api/trips/' + TRIP_ID + '/settlements?memberId=' + myMid;

  Promise.all([
    fetch(expUrl).then(function(r) { return r.ok ? r.json() : []; }),
    fetch(settleUrl).then(function(r) { return r.ok ? r.json() : {settlements:[]}; })
  ])
  .then(function(results) {
    var expenses     = (results[0] || []).map(normalizeRow);
    var existingList = (results[1] && results[1].settlements) ? results[1].settlements : [];

    /* ── 1단계: 지출 기반 P2P 정산 계산 ── */
    /* key = "fromMemberId_toMemberId" (from=돈 보내는 사람, to=결제자)
       value = { fromMid, toMid, fromNick, toNick, totalAmt, expenses:[...] } */
    var p2pMap = {};

    expenses.forEach(function(exp) {
      var payerId = Number(exp.payerId);
      var payerNick = exp.payerNickname || MEMBER_DICT[payerId] || '?';
      var participants = exp.participants || [];

      /* 참여자 1명 이하 → 개인 지출, 정산 제외 */
      if (participants.length <= 1) return;

      /* 결제자만 참여한 경우도 제외 */
      var nonPayerParticipants = participants.filter(function(p) {
        return p.memberId && Number(p.memberId) !== payerId;
      });
      if (!nonPayerParticipants.length) return;

      /* 각 참여자(결제자 제외)에 대해 정산 생성 */
      nonPayerParticipants.forEach(function(p) {
        var fromMid  = Number(p.memberId);         /* 돈 보내는 사람 (분담자) */
        var toMid    = payerId;                     /* 돈 받는 사람 (결제자) */
        var fromNick = p.memberNickname || p.nickname || MEMBER_DICT[fromMid] || '?';
        var amt      = Number(p.shareAmount || 0);
        if (amt <= 0) return;

        var key = fromMid + '_' + toMid;
        if (!p2pMap[key]) {
          p2pMap[key] = {
            fromMid: fromMid, toMid: toMid,
            fromNick: fromNick, toNick: payerNick,
            totalAmt: 0, expenses: []
          };
        }
        p2pMap[key].totalAmt += amt;
        p2pMap[key].expenses.push({
          expenseId: exp.expenseId,
          description: exp.description || '',
          category: exp.category || 'ETC',
          amount: Number(exp.amount || 0),
          shareAmount: amt,
          expenseDate: exp.expenseDate || ''
        });
      });
    });

    /* ── 2단계: 기존 settlement 배열로 저장
       ★ Bug Fix: 기존 key→단일값 방식은 같은 pair에 COMPLETED+PENDING이 있을 때
          마지막 값만 남아 PENDING이 안 보이거나, COMPLETED 때문에 카드 전체가 스킵됨.
          배열로 저장해서 COMPLETED 금액 차감 후 netAmt > 0이면 카드 표시.
    ── */
    var existingByKey = {};
    existingList.forEach(function(s) {
      var key = (s.fromMemberId||0) + '_' + (s.toMemberId||0);
      if (!existingByKey[key]) existingByKey[key] = [];
      existingByKey[key].push(s);
    });

    /* ── 3단계: 내가 관련된 정산만 분리 ── */
    var toRecv = []; /* 내가 받을 정산 (내가 결제자 = toMid === myMid) */
    var toSend = []; /* 내가 줘야 할 정산 (내가 분담자 = fromMid === myMid) */

    Object.keys(p2pMap).forEach(function(key) {
      var item = p2pMap[key];
      if (item.toMid === myMid)   toRecv.push(item);
      if (item.fromMid === myMid) toSend.push(item);
    });

    /* 지출이 없는 경우 */
    if (!toRecv.length && !toSend.length) {
      if (emptyEl) emptyEl.style.display = '';
      if (recvList) recvList.innerHTML = '';
      if (sendList) sendList.innerHTML = '';
      return;
    }

    /* ── 4단계: 내가 받을 정산 렌더 ── */
    var recvHtml = '';
    var hasRecv = false;
    toRecv.forEach(function(item) {
      var key       = item.fromMid + '_' + item.toMid;
      var settleArr = existingByKey[key] || [];

      /* ★ 완료된 정산 금액 합계 차감 → 실제 남은 미수금 계산 */
      var completedAmt = settleArr
        .filter(function(s) { return s.status === 'COMPLETED'; })
        .reduce(function(sum, s) { return sum + Number(s.amount || 0); }, 0);
      var netAmt = item.totalAmt - completedAmt;

      /* netAmt <= 0 이면 이미 완전히 정산된 pair → 스킵 */
      if (netAmt <= 0) return;
      hasRecv = true;

      /* PENDING / REQUESTED 상태인 기존 정산 (완료 처리 버튼용) */
      var pendingSettle = null;
      settleArr.forEach(function(s) {
        if (s.status === 'REQUESTED' || s.status === 'PENDING') pendingSettle = s;
      });

      var statusBadge, actionBtn;
      if (pendingSettle) {
        statusBadge = '<span class="settle-badge settle-badge--requested">📬 요청 전송됨</span>';
        actionBtn = '<button class="settle-action-btn settle-action-btn--complete" onclick="completeSettlement(this,' + pendingSettle.settlementId + ')">✅ 정산 완료 처리</button>';
      } else {
        statusBadge = '<span class="settle-badge settle-badge--pending">⏳ 미요청</span>';
        actionBtn = '<button class="settle-action-btn settle-action-btn--request" '
          + 'data-from-mid="' + item.fromMid + '" data-amount="' + netAmt + '" '
          + 'data-nick="' + _esc(item.fromNick) + '" '
          + 'onclick="requestSettlementBtn(this)">📬 정산 요청하기</button>';
      }

      recvHtml += _buildSettleCardV2({
        type: 'recv',
        otherNick: item.fromNick,
        amt: netAmt,
        direction: _esc(item.fromNick) + ' → 나',
        statusBadge: statusBadge,
        actionBtn: actionBtn,
        expenses: item.expenses,
        expenseCount: item.expenses.length
      });
    });

    if (recvList) {
      if (hasRecv) {
        recvList.innerHTML = '<div class="settle-section-label">💳 내가 받을 정산</div>'
          + '<div class="settle-section-hint">내가 결제(총대)한 지출에서 상대방 몫이에요</div>'
          + recvHtml;
      } else {
        recvList.innerHTML = '<div class="settle-section-label">💳 내가 받을 정산</div>'
          + '<div class="settle-none-msg">받을 정산이 없어요</div>';
      }
    }

    /* ── 5단계: 내가 줘야 할 정산 렌더 ── */
    var sendHtml = '';
    var hasSend = false;
    toSend.forEach(function(item) {
      var key       = item.fromMid + '_' + item.toMid;
      var settleArr = existingByKey[key] || [];

      /* ★ 완료된 정산 금액 합계 차감 */
      var completedAmt = settleArr
        .filter(function(s) { return s.status === 'COMPLETED'; })
        .reduce(function(sum, s) { return sum + Number(s.amount || 0); }, 0);
      var netAmt = item.totalAmt - completedAmt;

      if (netAmt <= 0) return;
      hasSend = true;

      var pendingSettle = null;
      settleArr.forEach(function(s) {
        if (s.status === 'REQUESTED' || s.status === 'PENDING') pendingSettle = s;
      });

      var statusBadge, subText;
      if (pendingSettle) {
        statusBadge = '<span class="settle-badge settle-badge--incoming">📬 요청받음</span>';
        subText = '<span class="settle-sub-text">송금 후 상대방이 완료 처리해요</span>';
      } else {
        statusBadge = '<span class="settle-badge settle-badge--pending">⏳ 대기 중</span>';
        subText = '<span class="settle-sub-text">상대방의 요청을 기다려주세요</span>';
      }

      sendHtml += _buildSettleCardV2({
        type: 'send',
        otherNick: item.toNick,
        amt: netAmt,
        direction: '나 → ' + _esc(item.toNick),
        statusBadge: statusBadge,
        actionBtn: subText,
        expenses: item.expenses,
        expenseCount: item.expenses.length
      });
    });

    if (sendList) {
      if (hasSend) {
        sendList.innerHTML = '<div class="settle-section-label">💸 내가 줘야 할 정산</div>'
          + '<div class="settle-section-hint">상대방이 총대한 지출에서 내 몫이에요</div>'
          + sendHtml;
      } else {
        sendList.innerHTML = '<div class="settle-section-label">💸 내가 줘야 할 정산</div>'
          + '<div class="settle-none-msg">줘야 할 정산이 없어요</div>';
      }
    }

    /* 전부 완료된 경우 */
    if (!hasRecv && !hasSend) {
      if (recvList) recvList.innerHTML = '';
      if (sendList) sendList.innerHTML = '<div class="settle-all-done">🎉 모든 정산이 완료됐어요!</div>';
    }
  })
  .catch(function(err) {
    console.warn('[Settlement] 탭 로드 실패:', err);
    if (emptyEl) emptyEl.style.display = '';
    if (recvList) recvList.innerHTML = '';
    if (sendList) sendList.innerHTML = '';
  });
}

/* 정산 카드 빌더 V2 — 포함된 지출 목록 표시 */
function _buildSettleCardV2(opts) {
  var typeClass = opts.type === 'recv' ? 'settle-card--recv' : 'settle-card--send';
  var otherNickSafe = String(opts.otherNick).replace(/'/g, "\\'");

  /* 포함된 지출 내역 토글 영역 */
  var expListId = 'settleExp_' + Math.random().toString(36).substr(2,6);
  var expListHtml = '';
  if (opts.expenses && opts.expenses.length) {
    expListHtml = '<div id="' + expListId + '" class="settle-card__expenses" style="display:none;">';
    opts.expenses.forEach(function(e) {
      var m = _cat(e.category);
      var date = e.expenseDate ? String(e.expenseDate).substring(5).replace(/-/g,'/') : '';
      expListHtml += '<div class="settle-card__exp-item" onclick="openExpenseDetail(' + e.expenseId + ')">'
        + '<span class="settle-card__exp-icon" style="background:' + m.light + ';">' + m.icon + '</span>'
        + '<div class="settle-card__exp-info">'
        +   '<div class="settle-card__exp-name">' + _esc(e.description) + '</div>'
        +   '<div class="settle-card__exp-meta">' + date + ' · ' + m.name + ' · 전체 ' + _fmtAmt(e.amount) + '</div>'
        + '</div>'
        + '<div class="settle-card__exp-share">' + _fmtAmt(e.shareAmount) + '</div>'
        + '</div>';
    });
    expListHtml += '</div>';
  }

  return '<div class="settle-card ' + typeClass + '">'
    + '<div class="settle-card__top">'
    +   '<div class="settle-card__avatar">' + String(opts.otherNick).substring(0,2) + '</div>'
    +   '<div class="settle-card__info">'
    +     '<div class="settle-card__direction">' + opts.direction + '</div>'
    +     '<div class="settle-card__hint">' + opts.expenseCount + '건의 지출 포함</div>'
    +   '</div>'
    +   '<div class="settle-card__amt ' + (opts.type==='recv' ? 'settle-card__amt--recv' : 'settle-card__amt--send') + '">'
    +     _fmtAmt(opts.amt)
    +   '</div>'
    + '</div>'
    + expListHtml
    + '<div class="settle-card__bottom">'
    +   opts.statusBadge
    +   '<div class="settle-card__action">'
    +     opts.actionBtn
    +     '<button class="settle-detail-link" onclick="event.stopPropagation();_toggleSettleExpenses(\'' + expListId + '\',this)">내역 보기 ▾</button>'
    +   '</div>'
    + '</div>'
    + '</div>';
}

/* 정산 카드 내 지출 목록 토글 */
function _toggleSettleExpenses(id, btn) {
  var el = document.getElementById(id);
  if (!el) return;
  var isOpen = el.style.display !== 'none';
  el.style.display = isOpen ? 'none' : '';
  if (btn) btn.textContent = isOpen ? '내역 보기 ▾' : '내역 접기 ▴';
}


/* 완료 내역 뷰 */
function _loadSettleDoneView() {
  var doneList = document.getElementById('settleDoneList');
  var doneEmpty = document.getElementById('settleDoneEmpty');
  var myMid = _getMyMid();
  if (!myMid || !doneList) return;

  doneList.innerHTML = '<div class="settle-loading">불러오는 중...</div>';
  if (doneEmpty) doneEmpty.style.display = 'none';

  fetch(CTX_PATH + '/api/trips/' + TRIP_ID + '/settlements?memberId=' + myMid)
    .then(function(r) { return r.ok ? r.json() : {settlements:[]}; })
    .then(function(data) {
      var completed = (data.settlements||[]).filter(function(s) {
        return s.status === 'COMPLETED'
          && (Number(s.fromMemberId)===myMid || Number(s.toMemberId)===myMid);
      });

      if (!completed.length) {
        doneList.innerHTML = '';
        if (doneEmpty) doneEmpty.style.display = '';
        return;
      }

      doneList.innerHTML = completed.map(function(s) {
        var isSentByMe = Number(s.fromMemberId) === myMid;
        var otherNick  = isSentByMe
          ? _esc(s.toMemberNickname||s.toNickname||'?')
          : _esc(s.fromMemberNickname||s.fromNickname||'?');
        var direction  = isSentByMe ? '보냄' : '받음';
        var dirClass   = isSentByMe ? 'settle-done-dir--sent' : 'settle-done-dir--recv';
        var settledDate = s.settledAt ? String(s.settledAt).substring(0,10).replace(/-/g,'.') : '';

        return '<div class="settle-card settle-card--done">'
          + '<div class="settle-card__top">'
          +   '<div class="settle-card__avatar settle-card__avatar--done">' + String(otherNick).substring(0,2) + '</div>'
          +   '<div class="settle-card__info">'
          +     '<div class="settle-card__direction">' + otherNick + '</div>'
          +     '<div class="settle-card__hint">' + settledDate + '</div>'
          +   '</div>'
          +   '<div class="settle-card__amt settle-card__amt--done">' + _fmtAmt(s.amount) + '</div>'
          + '</div>'
          + '<div class="settle-card__bottom">'
          +   '<span class="settle-badge settle-badge--done">✅ 완료</span>'
          +   '<span class="settle-done-dir ' + dirClass + '">' + direction + '</span>'
          +   '<button class="settle-del-btn" onclick="deleteSettlement(this,' + s.settlementId + ')" title="삭제">🗑</button>'
          + '</div>'
          + '</div>';
      }).join('');
    })
    .catch(function() {
      doneList.innerHTML = '<div class="settle-empty-msg">불러오기 실패</div>';
    });
}


/* ═══════════════════════════════════════════
   정산 액션 함수들
═══════════════════════════════════════════ */

/* 정산 요청하기 */
function requestSettlementBtn(btn) {
  var fromMid = parseInt(btn.getAttribute('data-from-mid'))||0;
  var amount  = parseFloat(btn.getAttribute('data-amount'))||0;
  var nick    = btn.getAttribute('data-nick')||'?';
  if (!fromMid||!amount) { showToast('⚠️ 정산 정보가 올바르지 않아요'); return; }
  btn.disabled = true; btn.textContent = '요청 중...';

  fetch(CTX_PATH + '/api/trips/' + TRIP_ID + '/settlements/request', {
    method: 'POST', headers: {'Content-Type':'application/json'},
    body: JSON.stringify({ fromMemberId: fromMid, amount: amount })
  })
  .then(function(r) { return r.ok ? r.json() : Promise.reject(r.status); })
  .then(function(data) {
    if (data.success) {
      showToast('📬 ' + nick + '님에게 정산을 요청했어요!');
      _loadSettleStatusView();
      _renderSettleStatusChip();
    } else {
      showToast('⚠️ ' + (data.message||'요청 실패'));
      btn.disabled = false; btn.textContent = '📬 정산 요청하기';
    }
  })
  .catch(function() {
    showToast('⚠️ 요청에 실패했어요');
    btn.disabled = false; btn.textContent = '📬 정산 요청하기';
  });
}

/* 정산 완료 처리 */
function completeSettlement(btn, settlementId) {
  if (!settlementId) { showToast('⚠️ 정산 ID가 없어요'); return; }
  if (!confirm('정산 완료 처리하시겠습니까?\n상대방에게 금액을 받으셨나요?')) return;
  btn.disabled = true; btn.textContent = '처리 중...';

  fetch(CTX_PATH + '/api/settlements/complete', {
    method: 'POST', headers: {'Content-Type':'application/json'},
    body: JSON.stringify({ settlementIds: [settlementId] })
  })
  .then(function(r) {
    if (r.ok) {
      showToast('✅ 정산 완료 처리됐어요!');
      _loadSettleStatusView();
      _renderSettleStatusChip();
    } else { btn.disabled=false; btn.textContent='✅ 정산 완료 처리'; showToast('⚠️ 처리에 실패했어요'); }
  })
  .catch(function() { btn.disabled=false; btn.textContent='✅ 정산 완료 처리'; showToast('⚠️ 서버 오류'); });
}

/* 정산 삭제 */
function deleteSettlement(btn, settlementId) {
  if (!settlementId) { showToast('⚠️ 정산 ID가 없어요'); return; }
  if (!confirm('이 정산 내역을 삭제할까요?')) return;
  btn.disabled = true;
  fetch(CTX_PATH + '/api/settlements/' + settlementId, { method:'DELETE' })
    .then(function(r) {
      if (r.ok || r.status===204) {
        showToast('🗑 삭제됐어요');
        if (_settleView === 'done') _loadSettleDoneView();
        else _loadSettleStatusView();
      } else { btn.disabled=false; showToast('⚠️ 삭제에 실패했어요'); }
    })
    .catch(function() { btn.disabled=false; showToast('⚠️ 서버 오류'); });
}

/* 저장된 정산 로드 (호환성) */
function loadSavedSettlements() { switchSettleView('done'); }


/* ═══════════════════════════════════════════
   지출 상세 모달 (수정 요구사항 2 — 전면 개선)
   정보 구역 명확 분리 + 영수증 이미지 UX
═══════════════════════════════════════════ */
function openExpenseDetail(expenseId) {
  var body = document.getElementById('expenseDetailBody');
  if (!body) return;
  body.innerHTML = '<div style="text-align:center;padding:40px;color:var(--light);">불러오는 중...</div>';
  openModal('expenseDetailModal');

  fetch(CTX_PATH + '/api/expenses/' + expenseId)
    .then(function(r) { return r.ok ? r.json() : Promise.reject(r.status); })
    .then(function(e) {
      var m = _cat(e.category);
      var date = e.expenseDate ? String(e.expenseDate).replace(/-/g,'.') : '';
      var hasMemo = !!(e.memo && String(e.memo).trim());
      var rawReceipt = e.receiptUrl || e.receipt_url || e.RECEIPT_URL || '';
      var hasReceipt = !!(rawReceipt && String(rawReceipt).trim());
      var participants = e.participants || [];

      var html = '';

      /* ── 히어로 영역 ── */
      html += '<div class="ed-hero">'
        + '<div class="ed-hero__icon" style="background:' + m.light + ';color:' + m.color + ';">' + m.icon + '</div>'
        + '<div class="ed-hero__amt">' + _fmtAmt(e.amount) + '</div>'
        + '<div class="ed-hero__name">' + _esc(e.description||'') + '</div>'
        + '</div>';

      /* ── 기본 정보 그리드 ── */
      html += '<div class="ed-info-grid">'
        + _edInfoItem('📅', '날짜', date)
        + _edInfoItem(m.icon, '카테고리', m.name)
        + _edInfoItem('👤', '결제자', _esc(e.payerNickname||'?'))
        + (e.paymentType ? _edInfoItem('💳', '결제 수단', _esc(e.paymentType)) : '')
        + '</div>';

      /* ── 분담 내역 ── */
      if (participants.length) {
        html += '<div class="ed-section">'
          + '<div class="ed-section__title">👥 분담 내역</div>'
          + '<div class="ed-participants">';
        participants.forEach(function(p) {
          var pName = _esc(p.memberNickname || p.nickname || p.nick || '?');
          var isExt = !p.memberId;
          html += '<div class="ed-participant">'
            + '<div class="ed-participant__avatar' + (isExt ? ' ed-participant__avatar--ext' : '') + '">' + String(pName).substring(0,2) + '</div>'
            + '<div class="ed-participant__name">' + pName + (isExt ? ' <span class="ed-ext-badge">외부</span>' : '') + '</div>'
            + '<div class="ed-participant__amt">' + _fmtAmt(p.shareAmount) + '</div>'
            + '</div>';
        });
        html += '</div></div>';
      }

      /* ── 메모 ── */
      if (hasMemo) {
        html += '<div class="ed-section">'
          + '<div class="ed-section__title">📝 메모</div>'
          + '<div class="ed-memo">' + _esc(String(e.memo).trim()) + '</div>'
          + '</div>';
      }

      /* ── 영수증 이미지 ── */
      if (hasReceipt) {
        var receiptUrl = String(rawReceipt).trim();
        html += '<div class="ed-section">'
          + '<div class="ed-section__title">📷 영수증</div>'
          + '<div class="ed-receipt">'
          +   '<div class="ed-receipt__thumb" onclick="openImageViewer(\'' + _esc(receiptUrl) + '\')">'
          +     '<img src="' + _esc(receiptUrl) + '" alt="영수증" onerror="this.parentNode.innerHTML=\'<div class=ed-receipt__err>이미지를 불러올 수 없어요</div>\'">'
          +     '<div class="ed-receipt__overlay">🔍 확대하기</div>'
          +   '</div>'
          + '</div>'
          + '</div>';
      }

      /* ── 빈 첨부 ── */
      if (!hasMemo && !hasReceipt) {
        html += '<div class="ed-empty-attach">첨부된 메모나 영수증이 없어요</div>';
      }

      body.innerHTML = html;
    })
    .catch(function() {
      body.innerHTML = '<div style="text-align:center;padding:30px;color:var(--light);">상세 정보를 불러오지 못했어요</div>';
    });
}

function _edInfoItem(icon, label, value) {
  return '<div class="ed-info-item">'
    + '<div class="ed-info-item__icon">' + icon + '</div>'
    + '<div class="ed-info-item__content">'
    +   '<div class="ed-info-item__label">' + label + '</div>'
    +   '<div class="ed-info-item__value">' + value + '</div>'
    + '</div>'
    + '</div>';
}


/* ═══════════════════════════════════════════
   내 지출 상세 모달
═══════════════════════════════════════════ */
function openMyExpenseDetail() {
  var body = document.getElementById('memberSettleBody');
  var title = document.getElementById('memberSettleTitle');
  if (!body||!title) return;
  var myMid = _getMyMid() || -1;
  title.textContent = '내 지출 내역';
  body.innerHTML = '<div style="text-align:center;padding:20px;color:var(--light);">불러오는 중...</div>';
  openModal('memberSettleModal');

  fetch(CTX_PATH + '/api/trips/' + TRIP_ID + '/expenses?page=1&size=200')
    .then(function(r) { return r.ok ? r.json() : []; })
    .then(function(list) {
      list = (list||[]).map(normalizeRow);
      var paidList = list.filter(function(e) { return Number(e.payerId)===myMid; });
      var paidTotal = paidList.reduce(function(s,e) { return s+Number(e.amount||0); }, 0);

      var html = '<div class="ms-stat-bar">'
        + '<div class="ms-stat"><div class="ms-stat-label">내 결제</div><div class="ms-stat-val">' + _fmtAmt(paidTotal) + '</div></div>'
        + '<div class="ms-stat"><div class="ms-stat-label">총 지출</div><div class="ms-stat-val">' + list.length + '건</div></div>'
        + '</div>';

      if (paidList.length) {
        html += '<div class="ms-section-head">💳 내가 결제한 지출</div>';
        html += paidList.map(function(e) {
          var m = _cat(e.category);
          var date = e.expenseDate ? String(e.expenseDate).substring(5).replace(/-/g,'/') : '';
          return '<div class="ms-expense-item" onclick="closeModal(\'memberSettleModal\');openExpenseDetail(' + e.expenseId + ')">'
            + '<span class="ms-cat-icon" style="background:' + m.light + ';">' + m.icon + '</span>'
            + '<div class="ms-item-info"><div class="ms-item-name">' + _esc(e.description||'') + '</div>'
            + '<div class="ms-item-date">' + date + '</div></div>'
            + '<div class="ms-item-amt">' + _fmtAmt(e.amount) + '</div>'
            + '</div>';
        }).join('');
      } else {
        html += '<div style="text-align:center;padding:20px;color:var(--light);font-size:13px;">아직 결제한 지출이 없어요</div>';
      }
      body.innerHTML = html;
    })
    .catch(function() { body.innerHTML = '<div style="text-align:center;padding:20px;color:var(--light);">불러오기 실패</div>'; });
}


/* ═══════════════════════════════════════════
   멤버 정산 상세 모달
═══════════════════════════════════════════ */
function openMemberSettleDetail(memberId, nickname) {
  var body = document.getElementById('memberSettleBody');
  var title = document.getElementById('memberSettleTitle');
  if (!body||!title) return;
  title.textContent = nickname + '님의 정산 현황';
  body.innerHTML = '<div style="text-align:center;padding:20px;color:var(--light);">불러오는 중...</div>';
  openModal('memberSettleModal');

  fetch(CTX_PATH + '/api/trips/' + TRIP_ID + '/expenses?page=1&size=200')
    .then(function(r) { return r.ok ? r.json() : []; })
    .then(function(list) {
      list = (list||[]).map(normalizeRow);
      var mid = Number(memberId);
      var paidList = list.filter(function(e) { return Number(e.payerId)===mid; });
      var paidTotal = paidList.reduce(function(s,e) { return s+Number(e.amount||0); }, 0);
      var html = '';
      if (paidList.length) {
        html += '<div class="ms-section-head">💳 ' + _esc(nickname) + '님이 결제한 지출</div>';
        html += '<div class="ms-section-total">총 ' + _fmtAmt(paidTotal) + ' 결제</div>';
        html += paidList.map(function(e) {
          var m = _cat(e.category);
          var date = e.expenseDate ? String(e.expenseDate).substring(5).replace(/-/g,'/') : '';
          return '<div class="ms-expense-item" onclick="closeModal(\'memberSettleModal\');openExpenseDetail(' + e.expenseId + ')">'
            + '<span class="ms-cat-icon" style="background:' + m.light + ';">' + m.icon + '</span>'
            + '<div class="ms-item-info"><div class="ms-item-name">' + _esc(e.description||'') + '</div>'
            + '<div class="ms-item-date">' + date + '</div></div>'
            + '<div class="ms-item-amt">' + _fmtAmt(e.amount) + '</div>'
            + '</div>';
        }).join('');
      }
      if (!paidList.length) html = '<div style="text-align:center;padding:24px;color:var(--light);font-size:13px;">관련 지출이 없어요</div>';
      body.innerHTML = html;
    })
    .catch(function() { body.innerHTML = '<div style="text-align:center;padding:20px;color:var(--light);">불러오기 실패</div>'; });
}


/* ═══════════════════════════════════════════
   카테고리 상세 모달
═══════════════════════════════════════════ */
function openCatDetail(category) {
  var body = document.getElementById('catDetailBody');
  var title = document.getElementById('catDetailTitle');
  if (!body||!title) return;
  var m = _cat(category);
  title.textContent = m.icon + ' ' + m.name + ' 상세';
  body.innerHTML = '<div style="text-align:center;padding:20px;color:var(--light);">불러오는 중...</div>';
  openModal('catDetailModal');

  fetch(CTX_PATH + '/api/trips/' + TRIP_ID + '/expenses?page=1&size=200')
    .then(function(r) { return r.ok ? r.json() : []; })
    .then(function(list) {
      list = (list||[]).map(normalizeRow);
      var filtered = list.filter(function(e) { return (e.category||'ETC').toUpperCase()===category; });
      if (!filtered.length) { body.innerHTML = '<div style="text-align:center;padding:20px;color:var(--light);">해당 카테고리 지출이 없어요</div>'; return; }
      var total = filtered.reduce(function(s,e) { return s+Number(e.amount||0); }, 0);
      body.innerHTML = '<div style="background:var(--bg);border-radius:10px;padding:12px 14px;margin-bottom:14px;display:flex;justify-content:space-between;align-items:center;">'
        + '<span style="font-size:12px;color:var(--light);font-weight:600;">' + filtered.length + '건</span>'
        + '<span style="font-size:18px;font-weight:900;color:#1A202C;">' + _fmtAmt(total) + '</span></div>'
        + filtered.map(function(e) {
          var date = e.expenseDate ? String(e.expenseDate).substring(5).replace(/-/g,'/') : '';
          return '<div class="settle-detail-expense-item" style="cursor:pointer;" onclick="closeModal(\'catDetailModal\');openExpenseDetail(' + e.expenseId + ')">'
            + '<div class="settle-detail-expense-item__name">' + _esc(e.description||'') + '</div>'
            + '<div class="settle-detail-expense-item__meta">'
            + '<span>' + date + ' · 결제: ' + _esc(e.payerNickname||'?') + '</span>'
            + '<span class="settle-detail-expense-item__share">' + _fmtAmt(e.amount) + '</span></div></div>';
        }).join('');
    })
    .catch(function() { body.innerHTML = '<div style="text-align:center;padding:20px;color:var(--light);">불러오기 실패</div>'; });
}


/* ═══════════════════════════════════════════
   지출 추가 (POST)
═══════════════════════════════════════════ */
function submitExpense() {
  var description = document.getElementById('exp-name').value.trim();
  var amount      = parseFloat(document.getElementById('exp-amt').value)||0;
  var category    = document.getElementById('exp-cat').value;
  var payerEl     = document.getElementById('exp-payer-value');
  var payerId     = payerEl ? parseInt(payerEl.value) : null;
  var expenseDate = document.getElementById('exp-date').value;
  var pmtTypeEl   = document.getElementById('exp-payment-type');
  var paymentType = pmtTypeEl ? pmtTypeEl.value : '';
  var memoEl      = document.getElementById('exp-memo');
  var memo        = memoEl ? memoEl.value.trim() : '';

  if (!description)               { showToast('⚠️ 항목명을 입력해주세요'); return; }
  if (amount <= 0)                { showToast('⚠️ 금액을 입력해주세요');   return; }
  if (!expenseDate)               { showToast('⚠️ 날짜를 선택해주세요');   return; }
  if (!payerId || isNaN(payerId)) { showToast('⚠️ 결제자를 선택해주세요'); return; }

  var allParts = _getAllParticipants();
  if (!allParts.length) { showToast('⚠️ 분담자를 1명 이상 선택해주세요'); return; }
  var wsParts = allParts.filter(function(p) { return String(p.id).indexOf('ext_')!==0; });
  if (!wsParts.length) { showToast('⚠️ 워크스페이스 참여자가 최소 1명 필요해요'); return; }

  var totalCnt = allParts.length;
  var basePerHead = Math.floor(amount/totalCnt);
  var remainder = amount - basePerHead*totalCnt;
  var participants = [];
  allParts.forEach(function(p,idx) {
    var isExt = String(p.id).indexOf('ext_')===0;
    participants.push({
      memberId: isExt ? null : parseInt(p.id),
      nickname: isExt ? p.nick : null,
      shareAmount: basePerHead + (idx===0 ? remainder : 0)
    });
  });

  var btn = document.querySelector('.exp-submit-btn') || document.getElementById('expSubmitBtn');
  if (btn) { btn.disabled=true; btn.textContent='추가 중...'; }

  var receiptFile = document.getElementById('exp-receipt');
  var uploadPromise;
  if (receiptFile && receiptFile.files && receiptFile.files[0]) {
    var fd = new FormData(); fd.append('file', receiptFile.files[0]);
    uploadPromise = fetch(CTX_PATH+'/api/upload/receipt', { method:'POST', body:fd })
      .then(function(r) { return r.ok ? r.json() : null; })
      .then(function(data) { return data&&data.url ? data.url : null; })
      .catch(function() { return null; });
  } else { uploadPromise = Promise.resolve(null); }

  uploadPromise.then(function(receiptUrl) {
    fetch(CTX_PATH + '/api/trips/' + TRIP_ID + '/expenses', {
      method: 'POST', headers: {'Content-Type':'application/json'},
      body: JSON.stringify({
        description: description, amount: amount, category: category,
        payerId: payerId, expenseDate: expenseDate,
        paymentType: paymentType||null, memo: memo||null,
        receiptUrl: receiptUrl||null, participants: participants
      })
    })
    .then(function(r) { if (!r.ok) return r.json().then(function(e){throw e;}); return r.json(); })
    .then(function() {
      closeModal('addExpenseModal');
      _resetExpenseForm();
      _wsParticipants=[]; _extraParticipants=[]; _extraIdCounter=0;
      showToast('✅ 지출이 추가됐어요!');
      var listBtn = document.querySelectorAll('.exp-itab')[1];
      switchExpTab('list', listBtn);
    })
    .catch(function(e) { alert((e&&e.message)||'지출 추가에 실패했어요.'); })
    .finally(function() {
      var _b = document.querySelector('.exp-submit-btn')||document.getElementById('expSubmitBtn');
      if (_b) { _b.disabled=false; _b.textContent='지출 추가하기'; }
    });
  });
}


/* ═══════════════════════════════════════════
   결제자 드롭다운
═══════════════════════════════════════════ */
function togglePayerMenu() {
  var btn=document.getElementById('expPayerBtn'), menu=document.getElementById('expPayerMenu');
  if (!btn||!menu) return;
  var isOpen = menu.classList.contains('open');
  menu.classList.toggle('open', !isOpen); btn.classList.toggle('open', !isOpen);
  if (!isOpen) setTimeout(function() { document.addEventListener('click', _closePayerMenuOutside, {once:true}); }, 0);
}
function _closePayerMenuOutside(e) {
  var dd=document.getElementById('expPayerDropdown');
  if (dd&&!dd.contains(e.target)) {
    document.getElementById('expPayerMenu').classList.remove('open');
    document.getElementById('expPayerBtn').classList.remove('open');
  }
}
function selectPayer(memberId, nickname, isMe) {
  var h=document.getElementById('exp-payer-value'); if (h) h.value=memberId;
  var l=document.getElementById('expPayerBtnLabel'); if (l) l.textContent=nickname+(isMe?' (나)':'');
  var a=document.getElementById('expPayerBtnAvatar'); if (a) a.textContent=String(nickname).substring(0,2);
  document.querySelectorAll('.exp-payer-option').forEach(function(opt) {
    var oid=parseInt(opt.getAttribute('data-id'));
    var chk=opt.querySelector('.exp-payer-option__check');
    opt.classList.toggle('selected', oid===memberId);
    if (chk) chk.style.display = (oid===memberId)?'':'none';
  });
  var menu=document.getElementById('expPayerMenu'), btn=document.getElementById('expPayerBtn');
  if (menu) menu.classList.remove('open'); if (btn) btn.classList.remove('open');
}


/* ═══════════════════════════════════════════
   분담자 관리
═══════════════════════════════════════════ */
var _wsParticipants=[], _extraParticipants=[], _extraIdCounter=0;
function _getAllParticipants() { return _wsParticipants.concat(_extraParticipants).filter(function(p){return p.checked;}); }

function _initParticipants() {
  if (_wsParticipants.length===0) {
    document.querySelectorAll('#expPayerMenu .exp-payer-option').forEach(function(opt) {
      var id=parseInt(opt.getAttribute('data-id'));
      var nick=opt.querySelector('.exp-payer-option__name');
      if (!id||!nick) return;
      _wsParticipants.push({id:id, nick:nick.textContent.trim(), checked:true});
    });
  }
  _renderSplitList();
}

function _renderSplitList() {
  var listEl=document.getElementById('exp-split-list'), cntEl=document.getElementById('expSplitCount'), noteEl=document.getElementById('exp-remainder-note');
  if (!listEl) return;
  var all=_getAllParticipants(), cnt=all.length;
  var amt=parseFloat(document.getElementById('exp-amt')&&document.getElementById('exp-amt').value)||0;
  if (cntEl) cntEl.textContent='친구 '+cnt+'명';
  if (!cnt) { listEl.innerHTML='<div style="text-align:center;padding:16px;color:var(--light);font-size:12px;">분담자를 선택해주세요</div>'; if(noteEl) noteEl.style.display='none'; _updateSubmitBtn(); return; }
  var base=amt>0?Math.floor(amt/cnt):0, remainder=amt>0?(amt-base*cnt):0;
  listEl.innerHTML = all.map(function(p,idx) {
    var share=base+(idx===0&&remainder>0?remainder:0);
    var isExt=String(p.id).indexOf('ext_')===0;
    return '<div class="exp-v2-split-item"><div class="exp-v2-split-avatar'+(isExt?' ext':'')+'">'+String(p.nick).substring(0,2)+'</div>'
      + '<div class="exp-v2-split-name">'+_esc(p.nick)+(isExt?' <span class="ext-badge">외부</span>':'')+'</div>'
      + '<div class="exp-v2-split-amt">'+(amt>0?_fmtAmt(share):'—')+'</div></div>';
  }).join('');
  if (noteEl) { if (remainder>0&&amt>0) { noteEl.style.display=''; noteEl.textContent='나머지 '+remainder+'원은 '+all[0].nick+'님에게 포함됩니다'; } else noteEl.style.display='none'; }
  _updateSubmitBtn();
}

function openParticipantEditor() {
  var wsEl=document.getElementById('peWsMembers'), extraEl=document.getElementById('peExtraMembers');
  if (!wsEl) return;
  wsEl.innerHTML = '<div style="font-size:11px;font-weight:800;color:var(--light);text-transform:uppercase;letter-spacing:.5px;margin-bottom:8px;">여행 참여자</div>'
    + _wsParticipants.map(function(p) {
      return '<div class="pe-member-row"><label style="display:flex;align-items:center;gap:10px;cursor:pointer;">'
        + '<input type="checkbox" '+(p.checked?'checked':'')+' data-id="'+p.id+'" onchange="_onPeCheck(this,false)">'
        + '<div class="pe-avatar">'+String(p.nick).substring(0,2)+'</div><span>'+_esc(p.nick)+'</span></label></div>';
    }).join('');
  extraEl.innerHTML = _extraParticipants.length
    ? '<div style="font-size:11px;font-weight:800;color:var(--light);text-transform:uppercase;letter-spacing:.5px;margin-bottom:8px;margin-top:14px;">추가한 인원</div>'
      + _extraParticipants.map(function(p) {
        return '<div class="pe-member-row"><label style="display:flex;align-items:center;gap:10px;cursor:pointer;">'
          + '<input type="checkbox" '+(p.checked?'checked':'')+' data-id="'+p.id+'" onchange="_onPeCheck(this,true)">'
          + '<div class="pe-avatar ext">'+String(p.nick).substring(0,2)+'</div><span>'+_esc(p.nick)+'</span></label>'
          + '<button onclick="removeExtraPerson(\''+p.id+'\')" style="background:none;border:none;color:var(--light);cursor:pointer;font-size:16px;">✕</button></div>';
      }).join('') : '';
  openModal('participantEditorModal');
}
function _onPeCheck(cb, isExtra) { var id=cb.getAttribute('data-id'), arr=isExtra?_extraParticipants:_wsParticipants, p=arr.find(function(x){return String(x.id)===String(id);}); if(p) p.checked=cb.checked; }
function addExtraPerson() {
  var input=document.getElementById('peExtraNameInput'); if(!input) return;
  var nick=input.value.trim(); if(!nick){alert('이름을 입력해주세요');return;}
  if(_extraParticipants.some(function(p){return p.nick===nick;})){alert('이미 추가된 이름이에요');return;}
  _extraIdCounter++; _extraParticipants.push({id:'ext_'+_extraIdCounter,nick:nick,checked:true});
  input.value=''; openParticipantEditor();
}
function removeExtraPerson(extId) { _extraParticipants=_extraParticipants.filter(function(p){return p.id!==extId;}); openParticipantEditor(); }
function applyParticipants() { closeModal('participantEditorModal'); _renderSplitList(); }

function _updateSubmitBtn() {
  var btn=document.getElementById('expSubmitBtn');
  var amt=parseFloat(document.getElementById('exp-amt')&&document.getElementById('exp-amt').value)||0;
  var name=document.getElementById('exp-name')&&document.getElementById('exp-name').value.trim();
  var cnt=_getAllParticipants().length;
  var ok=amt>0&&name&&cnt>0;
  if(btn){btn.disabled=!ok;btn.style.opacity=ok?'1':'0.45';}
}


/* ═══════════════════════════════════════════
   지출 폼 리셋 / 삭제 / 기타 유틸
═══════════════════════════════════════════ */
function _resetExpenseForm() {
  ['exp-name','exp-amt','exp-memo'].forEach(function(id){var el=document.getElementById(id);if(el)el.value='';});
  var pmtEl=document.getElementById('exp-payment-type'); if(pmtEl) pmtEl.value='';
  var menu=document.getElementById('expPayerMenu'), btn=document.getElementById('expPayerBtn');
  if(menu)menu.classList.remove('open'); if(btn)btn.classList.remove('open');
  var firstOpt=document.querySelector('.exp-payer-option');
  if(firstOpt){var fid=firstOpt.getAttribute('data-id'),fnick=firstOpt.querySelector('.exp-payer-option__name');selectPayer(parseInt(fid),fnick?fnick.textContent:'나',true);}
  document.querySelectorAll('#exp-participants input[type=checkbox]').forEach(function(cb){cb.checked=true;});
  var ri=document.getElementById('exp-receipt'); if(ri) ri.value='';
  var rp=document.getElementById('exp-receipt-preview'); if(rp){rp.innerHTML='';rp.style.display='none';}
  recalcSharePreview();
}

function deleteExpenseItem(expenseId) {
  if(!confirm('이 지출을 삭제할까요?')) return;
  fetch(CTX_PATH+'/api/expenses/'+expenseId, {method:'DELETE'})
    .then(function(r){if(r.ok){showToast('🗑️ 지출이 삭제됐어요');loadExpenseList();_loadHomeTab();}else showToast('⚠️ 삭제에 실패했어요');})
    .catch(function(){showToast('⚠️ 삭제에 실패했어요');});
}

function recalcSharePreview() {
  var amt=parseFloat(document.getElementById('exp-amt').value)||0;
  var checks=document.querySelectorAll('#exp-participants input[type=checkbox]:checked');
  var cnt=checks.length;
  var preview=document.getElementById('exp-share-preview'); if(!preview) return;
  if(cnt>0&&amt>0){var per=Math.floor(amt/cnt);
    preview.style.cssText='display:flex;align-items:baseline;gap:6px;margin-top:10px;padding:12px 14px;background:linear-gradient(120deg,rgba(137,207,240,.1),rgba(194,184,217,.07));border-radius:10px;border:1px solid rgba(137,207,240,.25)';
    preview.innerHTML='<span style="font-size:11px;font-weight:600;color:var(--light);">1인당</span><span style="font-size:22px;font-weight:900;color:#2B6CB0;letter-spacing:-1px;">'+_fmtAmt(per)+'</span>';
  } else { preview.style.cssText=''; preview.innerHTML=''; }
}

function selectExpCat(val,btn) {
  document.querySelectorAll('.exp-cat-chip').forEach(function(b){b.classList.remove('active');});
  btn.classList.add('active');
  var hidden=document.getElementById('exp-cat'); if(hidden) hidden.value=val;
}

function previewReceiptImage(input) {
  var preview=document.getElementById('exp-receipt-preview');
  if(!preview||!input.files||!input.files[0]) return;
  var reader=new FileReader();
  reader.onload=function(e){
    preview.innerHTML='<div style="position:relative;display:inline-block;">'
      + '<img src="'+e.target.result+'" style="max-width:100%;max-height:160px;border-radius:10px;border:1.5px solid var(--border);object-fit:cover;" />'
      + '<button type="button" onclick="removeReceiptImage()" style="position:absolute;top:-8px;right:-8px;width:22px;height:22px;border-radius:50%;background:#FC8181;border:none;color:white;font-size:11px;font-weight:700;cursor:pointer;display:flex;align-items:center;justify-content:center;">✕</button></div>';
    preview.style.display='block';
  };
  reader.readAsDataURL(input.files[0]);
}
function removeReceiptImage() {
  var i=document.getElementById('exp-receipt'),p=document.getElementById('exp-receipt-preview');
  if(i) i.value=''; if(p){p.innerHTML='';p.style.display='none';}
}


/* ═══════════════════════════════════════════
   DOMContentLoaded
═══════════════════════════════════════════ */
document.addEventListener('DOMContentLoaded', function() {
  _loadHomeTab();
  var firstSelected = document.querySelector('.exp-payer-option.selected');
  if(firstSelected){var fid=parseInt(firstSelected.getAttribute('data-id')),fnick=firstSelected.querySelector('.exp-payer-option__name');if(fnick)selectPayer(fid,fnick.textContent,true);}

  document.addEventListener('click', function(e) {
    if(e.target&&e.target.getAttribute&&e.target.getAttribute('onclick')==="openModal('addExpenseModal')"){
      setTimeout(function(){if(_wsParticipants.length===0)_initParticipants();else _renderSplitList();_initCatChipDrag();},80);
    }
  });

  var expDateEl=document.getElementById('exp-date');
  if(expDateEl&&!expDateEl.value){var today=new Date();expDateEl.value=today.getFullYear()+'-'+String(today.getMonth()+1).padStart(2,'0')+'-'+String(today.getDate()).padStart(2,'0');}
  var amtEl=document.getElementById('exp-amt'); if(amtEl) amtEl.addEventListener('input', recalcSharePreview);
  _initCatChipDrag();

  document.addEventListener('input', function(e) {
    if(e.target&&(e.target.id==='exp-amt'||e.target.id==='exp-name')){_renderSplitList();_updateSubmitBtn();}
  });
});

function _initCatChipDrag() {
  var el=document.getElementById('expCatChips'); if(!el) return;
  var isDown=false, startX, scrollLeft;
  el.addEventListener('mousedown', function(e){isDown=true;startX=e.pageX-el.offsetLeft;scrollLeft=el.scrollLeft;el.style.cursor='grabbing';});
  el.addEventListener('mouseleave', function(){isDown=false;el.style.cursor='grab';});
  el.addEventListener('mouseup', function(){isDown=false;el.style.cursor='grab';});
  el.addEventListener('mousemove', function(e){if(!isDown)return;e.preventDefault();var x=e.pageX-el.offsetLeft;el.scrollLeft=scrollLeft-(x-startX)*1.5;});
}


/* ═══════════════════════════════════════════
   정산 상세 모달 (기존 호환)
═══════════════════════════════════════════ */
function openSettleDetailBtn(btn) {
  var sid=btn.getAttribute('data-sid')||null, from=btn.getAttribute('data-from')||'?', to=btn.getAttribute('data-to')||'?', amt=parseFloat(btn.getAttribute('data-amt'))||0;
  openSettleDetail(sid?parseInt(sid):null, from, to, amt);
}
function openSettleDetail(settlementId, from, to, amount) {
  var body=document.getElementById('settleDetailBody'); if(!body) return;

  body.innerHTML='<div class="settle-detail-kp-header">'
    + '<div class="settle-detail-kp-amt">' + _fmtAmt(amount) + '</div>'
    + '<div class="settle-detail-kp-desc">'
    +   '<span class="settle-detail-kp-from">' + _esc(from) + '</span>'
    +   '<span class="settle-detail-kp-arrow"> → </span>'
    +   '<span class="settle-detail-kp-to">' + _esc(to) + '</span>님께'
    + '</div></div>'
    + '<div class="settle-detail-section-title">관련 지출 내역</div>'
    + '<div id="settleDetailExpenses"><div style="text-align:center;padding:24px;color:var(--light);font-size:13px;">불러오는 중...</div></div>'
    + '<div id="settleDetailImages" style="display:none;">'
    + '<div class="settle-detail-section-title" style="margin-top:16px;">영수증 모아보기</div>'
    + '<div id="settleDetailImgGrid" class="settle-detail-img-grid"></div></div>';

  openModal('settleDetailModal');

  fetch(CTX_PATH + '/api/trips/' + TRIP_ID + '/expenses?page=1&size=50')
    .then(function(r) { return r.ok ? r.json() : []; })
    .then(function(list) {
      list = (list||[]).map(normalizeRow);
      var detailEl = document.getElementById('settleDetailExpenses');
      var imagesEl = document.getElementById('settleDetailImages');
      var imgGrid  = document.getElementById('settleDetailImgGrid');
      if (!detailEl) return;

      if (!list.length) {
        detailEl.innerHTML = '<div style="text-align:center;padding:20px;color:var(--light);font-size:13px;">관련 지출이 없어요</div>';
        return;
      }

      /* 카테고리별 그룹핑 */
      var groups = {}, receipts = [];
      list.forEach(function(e) {
        var k = (e.category||'ETC').toUpperCase();
        if (!groups[k]) groups[k] = { items: [], total: 0 };
        groups[k].items.push(e);
        groups[k].total += Number(e.amount||0);
        if (e.receiptUrl) receipts.push({ url: e.receiptUrl, name: e.description });
      });

      var html = '';
      _CAT_ORDER.concat(Object.keys(groups).filter(function(k){ return _CAT_ORDER.indexOf(k)===-1; }))
        .filter(function(k){ return groups[k]; })
        .forEach(function(k) {
          var g = groups[k];
          var m = _cat(k);
          html += '<div class="settle-cat-group">'
            + '<div class="settle-cat-group__head"><span>' + m.icon + ' ' + m.name + '</span>'
            + '<span class="settle-cat-group__total">' + _fmtAmt(g.total) + '</span></div>';
          g.items.forEach(function(e) {
            html += '<div class="settle-cat-item">'
              + '<div class="settle-cat-item__avatar">' + String(e.payerNickname||'?').substring(0,2) + '</div>'
              + '<div class="settle-cat-item__info">'
              +   '<div class="settle-cat-item__name">' + _esc(e.description||'') + '</div>'
              +   '<div class="settle-cat-item__sub">' + (e.expenseDate?String(e.expenseDate).substring(5).replace(/-/g,'/'):'') + ' · 결제: ' + _esc(e.payerNickname||'?') + '</div>'
              + '</div>'
              + '<div class="settle-cat-item__amt">' + _fmtAmt(e.amount) + '</div>'
              + (e.receiptUrl ? '<button class="settle-cat-item__img-btn" onclick="openImageViewer(\'' + _esc(e.receiptUrl) + '\')" title="영수증 보기">📷</button>' : '')
              + '</div>';
          });
          html += '</div>';
        });
      detailEl.innerHTML = html;

      /* 영수증 그리드 */
      if (receipts.length > 0 && imgGrid && imagesEl) {
        imgGrid.innerHTML = receipts.map(function(r) {
          return '<div class="settle-receipt-thumb" onclick="openImageViewer(\'' + _esc(r.url) + '\')"><img src="' + _esc(r.url) + '" alt="' + _esc(r.name||'') + '" /></div>';
        }).join('');
        imagesEl.style.display = '';
      }
    })
    .catch(function() {
      var el = document.getElementById('settleDetailExpenses');
      if (el) el.innerHTML = '<div style="text-align:center;padding:20px;color:var(--light);font-size:13px;">불러오기 실패</div>';
    });
}
