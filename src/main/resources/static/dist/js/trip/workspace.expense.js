/**
 * workspace_expense.js — 전면 개편
 * ──────────────────────────────────────────────────────────
 * 담당: 가계부 · 정산 CRUD + 내부 3탭 (홈 / 내역 / 정산)
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
  DRINK:         { icon: '🍺', name: '술',     color: '#EAB308', bg: 'linear-gradient(135deg,#EAB308,#FDE047)', light: 'rgba(234,179,8,.12)' },
  SNACK:         { icon: '🍩', name: '간식',   color: '#D946EF', bg: 'linear-gradient(135deg,#D946EF,#F5D0FE)', light: 'rgba(217,70,239,.12)' },
  ETC:           { icon: '📦', name: '기타',   color: '#94A3B8', bg: 'linear-gradient(135deg,#94A3B8,#CBD5E1)', light: 'rgba(148,163,184,.12)' }
};
var _CAT_ORDER = ['FOOD', 'CAFE', 'DRINK', 'SNACK', 'TRANSPORT', 'ACCOMMODATION', 'TOUR', 'SHOPPING', 'ETC'];
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

      /* ★ myShare가 0이고 memberShares에 내 항목이 없는 경우
         (정산 연결 없는 상태인데도 0이 나오는 버그):
         with-participants API로 직접 계산해서 표시 */
      if (myShare === 0 && !myEntry) {
        fetch(CTX_PATH + '/api/trips/' + TRIP_ID + '/expenses/with-participants')
          .then(function(r) { return r.ok ? r.json() : []; })
          .then(function(expenses) {
            var calc = 0;
            (expenses || []).forEach(function(exp) {
              (exp.participants || []).forEach(function(p) {
                if (Number(p.memberId) === myMid) {
                  calc += Number(p.shareAmount || 0);
                }
              });
            });
            _setText('myShareAmt', _fmtAmt(calc));
          })
          .catch(function() { _setText('myShareAmt', _fmtAmt(0)); });
      } else {
        _setText('myShareAmt', _fmtAmt(myShare));
      }

      /* ── 받을/보낼 예정 금액 ── */
      var recvEl = document.getElementById('myReceiveAmt');
      var sendEl = document.getElementById('mySendAmt');
      if (recvEl) recvEl.textContent = myBal > 0 ? _fmtAmt(myBal) : '₩ 0';
      if (sendEl) sendEl.textContent = myBal < 0 ? _fmtAmt(Math.abs(myBal)) : '₩ 0';

      /* ── 나의 잔액 상태 ── */
      var myBalEl = document.getElementById('myBalanceLine');
      if (myBalEl) myBalEl.innerHTML = '';

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
      var incoming = list.filter(function(s) {
        return (s.status === 'REQUESTED' || s.status === 'PENDING')
          && Number(s.fromMemberId) === myMid;
      });
	  if (!incoming.length) { el.innerHTML = ''; return; }
	        el.innerHTML = '<div class="exp-home-settle-chip" onclick="switchExpTab(\'settle\', document.querySelectorAll(\'.exp-itab\')[2])">'
	          + '<div class="exp-home-settle-chip__left">'
	          +   '<div class="exp-home-settle-chip__icon-bg">📬</div>'
	          +   '<div class="exp-home-settle-chip__text">'
	          +     '<div class="exp-home-settle-chip__title">정산 요청이 도착했어요!</div>'
	          +     '<div class="exp-home-settle-chip__sub">' + incoming.length + '건의 요청 대기 중 · 눌러서 확인</div>'
	          +   '</div>'
	          + '</div>'
	          + '<div class="exp-home-settle-chip__right">〉</div>'
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

  var cardsHtml = ordered.map(function(catItem) {
    var k   = (catItem.category||'ETC').toUpperCase();
    var m   = _cat(k);
    var amt = Number(catItem.totalAmount||0);
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

  /* < > 네비게이션 버튼 포함 렌더 */
  var showNav = ordered.length > 2;
  section.innerHTML =
    '<div class="exp-home-section-title">📊 카테고리별 지출</div>'
    + '<div class="exp-cats-nav-wrap">'
    + (showNav ? '<button class="exp-cats-nav-btn exp-cats-nav-btn--l" id="catNavL" onclick="_scrollCats(-1)">&#8249;</button>' : '')
    + '<div class="expense-cats" id="expCatsInner">' + cardsHtml + '</div>'
    + (showNav ? '<button class="exp-cats-nav-btn exp-cats-nav-btn--r" id="catNavR" onclick="_scrollCats(1)">&#8250;</button>' : '')
    + '</div>';
}


/* 카테고리 네비게이션 스크롤 */
function _scrollCats(dir) {
  var inner = document.getElementById('expCatsInner');
  if (inner) inner.scrollBy({ left: dir * 140, behavior: 'smooth' });
}

/* ─── 내 지출 요약 (수정 요구사항 3 — "나" 중심, 결제/부담 중복 제거) ─── */
function _renderMyExpenseSummaryV2(myPaid, myShare, myBal, categoryBreakdown, memberShares, myMid) {
  var el = document.getElementById('expMySummarySection');
  if (!el) return;
  if (!myMid || (myPaid === 0 && myShare === 0)) { el.style.display='none'; return; }
  el.style.display = '';

  /* ★ 수정: 배지 제거 — 카테고리 분석만 */
  var summaryBody = document.getElementById('expMySummaryBody');
  summaryBody.innerHTML = ''
    + '<div id="myCatBreakdown" class="my-cat-breakdown"></div>'
    + '<div id="myRecentExpense" class="my-recent-expense"></div>'
    + '<button class="exp-my-detail-btn" onclick="openMyExpenseDetail()">내 지출 상세 보기 →</button>';

  /* 내 지출 요약: with-participants(shareAmount) + settlements 동시 조회 */
  Promise.all([
    fetch(CTX_PATH + '/api/trips/' + TRIP_ID + '/expenses/with-participants')
      .then(function(r) { return r.ok ? r.json() : []; }),
    fetch(CTX_PATH + '/api/trips/' + TRIP_ID + '/settlements?memberId=' + myMid)
      .then(function(r) { return r.ok ? r.json() : {}; })
  ])
  .then(function(res) {
    var allExp = (res[0] || []);
    var settleData = res[1] || {};
    var settlements = (settleData.settlements || []);

    /* ── 내 카테고리 분석: 참여자 기반 shareAmount 합산 ── */
    var catMap = {};
    allExp.forEach(function(exp) {
      var k = (exp.category||'ETC').toUpperCase();
      (exp.participants || []).forEach(function(p) {
        if (Number(p.memberId) === myMid) {
          if (!catMap[k]) catMap[k] = 0;
          catMap[k] += Number(p.shareAmount || 0);
        }
      });
    });

    var catEntries = Object.keys(catMap).map(function(k) { return { cat: k, amt: catMap[k] }; })
      .sort(function(a,b) { return b.amt - a.amt; });

    if (catEntries.length) {
      var catHtml = '<div class="my-cat-bd__title">내가 가장 많이 쓴 카테고리</div>';
      catHtml += catEntries.slice(0, 5).map(function(ce, i) {
        var m = _cat(ce.cat);
        var maxAmt = catEntries[0].amt || 1;
        var barW = Math.round(ce.amt / maxAmt * 100);
        return '<div class="my-cat-bd__row">'
          + '<div class="my-cat-bd__left">'
          +   '<span class="my-cat-bd__rank">' + (i+1) + '</span>'
          +   '<span class="my-cat-bd__icon" style="background:' + m.light + ';">' + m.icon + '</span>'
          +   '<span class="my-cat-bd__name">' + m.name + '</span>'
          + '</div>'
          + '<div class="my-cat-bd__right">'
          +   '<div class="my-cat-bd__bar"><div class="my-cat-bd__bar-fill" style="width:' + barW + '%;background:' + m.color + ';"></div></div>'
          +   '<span class="my-cat-bd__amt">' + _fmtAmt(ce.amt) + '</span>'
          + '</div>'
          + '</div>';
      }).join('');
      var catEl = document.getElementById('myCatBreakdown');
      if (catEl) catEl.innerHTML = catHtml;
    }

    /* ── 최근 활동: 내가 결제한 지출 + 내가 완료한 정산 ── */
    var recentEl = document.getElementById('myRecentExpense');
    if (!recentEl) return;

    /* 내가 결제한 지출 (최대 3건) */
    var myPayments = allExp
      .filter(function(e) { return Number(e.payerId) === myMid; })
      .sort(function(a,b) { return String(b.expenseDate||'').localeCompare(String(a.expenseDate||'')); })
      .slice(0, 3)
      .map(function(e) {
        return { type: 'pay', expenseId: e.expenseId, desc: e.description||'', cat: e.category||'ETC', amt: Number(e.amount||0), date: e.expenseDate||'' };
      });

    /* 내가 송금 완료한 정산 (status=COMPLETED, fromMemberId=나)
     * ★ 수정: settlement 1건 = 최근 활동 1줄
     *   - 단건 정산은 settlementId별로 각각 표시
     *   - 배치 정산은 batchId 단위로 묶되, to가 다른 경우 각각 표시
     *   - 절대로 금액을 합산하지 않음 */
    var mySentRaw = settlements.filter(function(s) {
      return s.status === 'COMPLETED' && Number(s.fromMemberId) === myMid;
    });
    /* batchId가 있어도 to가 다르면 별도 항목으로 표시 → key = batchId_toMemberId */
    var batchSentMap = {};
    mySentRaw.forEach(function(s) {
      var toId  = s.toMemberId || s.toMemberNickname || '?';
      var key   = s.batchId ? (String(s.batchId) + '_' + toId) : ('single_' + s.settlementId);
      if (!batchSentMap[key]) {
        batchSentMap[key] = {
          toNick: s.toMemberNickname || s.toNickname || '?',
          amt: 0,
          date: s.settledAt || s.createdAt || ''
        };
      }
      /* 같은 batch+to 조합이면 합산(원래 의도), 다르면 별도 key라 안 합산됨 */
      batchSentMap[key].amt += Number(s.amount || 0);
    });
    var mySent = Object.keys(batchSentMap).slice(0, 2).map(function(key) {
      var g = batchSentMap[key];
      return { type: 'settle', desc: g.toNick + '에게 송금', cat: 'SETTLE', amt: g.amt, date: g.date };
    });

    var recentAll = myPayments.concat(mySent)
      .sort(function(a,b) { return String(b.date).localeCompare(String(a.date)); })
      .slice(0, 4);

    if (recentAll.length) {
      var recentHtml = '<div class="my-cat-bd__title" style="margin-top:14px;">최근 활동</div>';
      recentHtml += recentAll.map(function(item) {
        var m = item.cat === 'SETTLE' ? { icon: '💸', light: '#FFF5F5', name: '송금' } : _cat(item.cat);
        var dateStr = item.date ? String(item.date).substring(5, 10).replace(/-/g,'/') : '';
        var typeBadge = item.type === 'pay'
          ? '<span class="my-recent-badge my-recent-badge--pay">결제</span>'
          : '<span class="my-recent-badge my-recent-badge--settle">송금</span>';
        var clickAttr = item.type === 'pay' ? ' onclick="openExpenseDetail(' + item.expenseId + ')"' : '';
        return '<div class="my-recent-item"' + clickAttr + (item.type === 'pay' ? ' style="cursor:pointer;"' : '') + '>'
          + '<div class="my-recent-item__icon" style="background:' + m.light + ';">' + m.icon + '</div>'
          + '<div class="my-recent-item__info">'
          +   '<div class="my-recent-item__name">' + _esc(item.desc) + ' ' + typeBadge + '</div>'
          +   '<div class="my-recent-item__meta">' + dateStr + ' · ' + m.name + '</div>'
          + '</div>'
          + '<div class="my-recent-item__amt' + (item.type === 'settle' ? ' my-recent-item__amt--settle' : '') + '">' + (item.type === 'settle' ? '-' : '') + _fmtAmt(item.amt) + '</div>'
          + '</div>';
      }).join('');
      recentEl.innerHTML = recentHtml;
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

  var myMid = _getMyMid() || 0;

  /* settlements API 동시 호출: 타임스탬프로 정확히 판별
     - expense.createdAt < settlement.settledAt → SETTLED (이 expense가 정산됐을 당시)
     - expense.createdAt >= settlement.settledAt → UNSETTLED (정산 완료 후 새로 추가된 것) */
  Promise.all([
    fetch(CTX_PATH + '/api/trips/' + TRIP_ID + '/expenses?page=1&size=50')
      .then(function(r) { return r.ok ? r.json() : Promise.reject(r.status); }),
    fetch(CTX_PATH + '/api/trips/' + TRIP_ID + '/settlements?memberId=' + myMid)
      .then(function(r) { return r.ok ? r.json() : {settlements:[]}; })
  ])
    .then(function(results) {
      var list = (results[0]||[]).map(normalizeRow);
      var settlements = ((results[1]||{}).settlements||[]).map(normalizeRow);

      /* pair별 COMPLETED 정산 목록 (toMemberId=결제자 기준) */
      var completedByPayer = {};
      settlements.forEach(function(s) {
        if (s.status === 'COMPLETED' && s.settledAt) {
          var toMid = s.toMemberId || 0;
          if (!completedByPayer[toMid]) completedByPayer[toMid] = [];
          completedByPayer[toMid].push(new Date(s.settledAt).getTime());
        }
      });

      /* pair별 PENDING/REQUESTED 결제자 목록 */
      var pendingPayers = {};
      settlements.forEach(function(s) {
        if (s.status === 'REQUESTED' || s.status === 'PENDING') {
          pendingPayers[s.toMemberId || 0] = true;
        }
      });

      /* expense별 settle_status 결정
         우선순위: DB settle_status(배치 정산) > 타임스탬프 기반(단건 정산) */
      list = list.map(function(e) {
        /* 배치 정산으로 이미 SETTLED/PENDING이면 그대로 */
        var dbSs = (e.settleStatus || 'UNSETTLED').toUpperCase();
        if (dbSs === 'SETTLED') return e;
        if (dbSs === 'PENDING') return e;

        var payerId = Number(e.payerId);
        var expTs   = e.createdAt ? new Date(e.createdAt).getTime() : 0;

        /* 이 결제자에 대한 완료된 정산 중, expense 생성 이후에 완료된 것이 있으면 SETTLED */
        var completedTimes = completedByPayer[payerId] || [];
        var isSettled = completedTimes.some(function(t) { return t > expTs; });
        if (isSettled) return Object.assign({}, e, { settleStatus: 'SETTLED' });

        /* 이 결제자에 대한 진행 중 정산이 있으면 PENDING */
        if (pendingPayers[payerId]) return Object.assign({}, e, { settleStatus: 'PENDING' });

        return e;
      });

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
          var ss = (e.settleStatus || 'UNSETTLED').toUpperCase();
          /* ★ border-left inline style 대신 CSS 변수 --accent 사용
             → trip.css의 border !important와 충돌 없음 */
          var accentColor = ss === 'SETTLED' ? '#10B981'
                          : ss === 'PENDING' ? '#F59E0B'
                          : m.color;
          var cardBg = ss === 'SETTLED'
            ? 'background:linear-gradient(135deg,rgba(16,185,129,0.05),#fff);'
            : ss === 'PENDING'
            ? 'background:linear-gradient(135deg,rgba(245,158,11,0.05),#fff);'
            : '';
          var ssCheck = ss === 'SETTLED' ? '<span class="exp-settle-check settled">✓</span>' : '';
          var ssBadge = ss === 'SETTLED'
            ? '<span class="exp-settle-badge exp-settle-badge--settled">✅ 정산 완료</span>'
            : ss === 'PENDING'
            ? '<span class="exp-settle-badge exp-settle-badge--pending">⏳ 정산 중</span>'
            : '';
          var date = e.expenseDate ? String(e.expenseDate).substring(5).replace(/-/g,'/') : '';
          html += '<div class="expense-item" style="--accent:' + accentColor + ';' + cardBg + '" data-expense-id="' + e.expenseId + '">'
            + '<div class="expense-item__cat-icon" style="background:' + m.light + ';color:' + m.color + ';">' + m.icon + '</div>'
            + '<div class="expense-item__info">'
            +   '<div class="expense-item__name">' + ssCheck + _esc(e.description||'') + '</div>'
            +   '<div class="expense-item__meta">'
            +     '<span class="expense-item__cat-badge" style="background:' + m.light + ';color:' + m.color + ';">' + m.name + '</span>'
            +     '<span class="expense-item__payer">👤 ' + _esc(e.payerNickname||'?') + '</span>'
            +     (hasMemo ? '<span class="expense-extra-badge">📝</span>' : '')
            +     (hasReceipt ? '<span class="expense-extra-badge expense-extra-badge--img">📷</span>' : '')
            +   '</div>'
            +   '<div class="expense-item__date-row">' + date + (ssBadge ? ' ' + ssBadge : '') + '</div>'
            + '</div>'
            + '<div class="expense-item__right">'
            +   '<div class="expense-item__amt">' + _fmtAmt(e.amount) + '</div>'
            +   '<button class="expense-del-btn" data-del-id="' + e.expenseId + '" title="삭제">✕</button>'
            + '</div>'
            + '</div>';
        });
        html += '</div>';
      });
      listEl.innerHTML = html;

      /* ★ 수정: 이벤트 위임으로 클릭/삭제 처리
         - 삭제 버튼(data-del-id)을 클릭하면 deleteExpenseItem 호출
         - 그 외 expense-item 클릭은 openExpenseDetail 호출
         - 이 방식은 stopPropagation 없이도 정확하게 분기됨 */
      listEl.addEventListener('click', function(e) {
        /* 삭제 버튼 또는 그 자식 요소 클릭 */
        var delBtn = e.target.closest ? e.target.closest('[data-del-id]') : null;
        if (!delBtn && e.target.getAttribute) {
          /* closest 미지원 브라우저 fallback */
          delBtn = e.target.getAttribute('data-del-id') ? e.target : null;
        }
        if (delBtn) {
          e.stopPropagation();
          e.preventDefault();
          deleteExpenseItem(parseInt(delBtn.getAttribute('data-del-id')));
          return;
        }
        /* 지출 카드 클릭 → 상세 모달 */
        var card = e.target.closest ? e.target.closest('.expense-item') : null;
        if (card && card.getAttribute('data-expense-id')) {
          openExpenseDetail(parseInt(card.getAttribute('data-expense-id')));
        }
      }, { once: false });
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
  var expUrl     = CTX_PATH + '/api/trips/' + TRIP_ID + '/expenses/with-participants';
  var settleUrl  = CTX_PATH + '/api/trips/' + TRIP_ID + '/settlements?memberId=' + myMid;
  var summaryUrl = CTX_PATH + '/api/trips/' + TRIP_ID + '/expenses?page=1&size=500';

  Promise.all([
    fetch(expUrl).then(function(r)    { return r.ok ? r.json() : []; }),
    fetch(settleUrl).then(function(r) { return r.ok ? r.json() : {settlements:[]}; }),
    fetch(summaryUrl).then(function(r){ return r.ok ? r.json() : []; })
  ])
  .then(function(results) {
    var expenses     = (results[0] || []).map(normalizeRow);
    var existingList = (results[1] && results[1].settlements) ? results[1].settlements : [];

    /*
     * ══════════════════════════════════════════════════════════
     * 정산 현황 계산 — 최종 올바른 버전
     *
     * 원칙: "모든 expense 부채 합계 - 모든 COMPLETED 정산 합계 = 남은 부채"
     *
     * [왜 이 방식인가]
     * 기존 방식들의 공통 결함:
     * - completedPairs: pair 전체를 skip → 새 지출도 skip됨
     * - settledExpenseMap + singleCompletedAmt: 두 방식이 배치/단건을
     *   서로 다른 방식으로 처리하다 케이스마다 구멍이 생김
     *
     * 이 방식은 단순하고 모든 케이스에서 정확:
     * - 단건 정산 완료 후 새 지출 추가 → netAmt = 새 지출 금액 만큼 증가 ✓
     * - 배치 정산 완료 후 새 지출 추가 → netAmt = 새 지출 금액만큼 증가 ✓
     * - 정산 완료 후 새 지출 없음 → netAmt = 0 → 카드 사라짐 ✓
     * ══════════════════════════════════════════════════════════
     */
    var p2pMap = {};

    /* 1) 모든 expense의 pair별 부채 합산 (필터 없음) */
    expenses.forEach(function(exp) {
      var payerId   = Number(exp.payerId);
      var payerNick = exp.payerNickname || MEMBER_DICT[payerId] || '?';
      var participants = exp.participants || [];

      if (participants.length <= 1) return;

      var nonPayers = participants.filter(function(p) {
        return p.memberId && Number(p.memberId) !== payerId;
      });
      if (!nonPayers.length) return;

      nonPayers.forEach(function(p) {
        var fromMid  = Number(p.memberId);
        var toMid    = payerId;
        var fromNick = p.memberNickname || p.nickname || MEMBER_DICT[fromMid] || '?';
        var amt      = Number(p.shareAmount || 0);
        if (amt <= 0) return;

        var key = fromMid + '_' + toMid;
        if (!p2pMap[key]) {
          p2pMap[key] = { fromMid: fromMid, toMid: toMid,
            fromNick: fromNick, toNick: payerNick, totalAmt: 0, expenses: [] };
        }
        p2pMap[key].totalAmt += amt;
        p2pMap[key].expenses.push({
          expenseId: exp.expenseId, description: exp.description || '',
          category: exp.category || 'ETC', amount: Number(exp.amount || 0),
          shareAmount: amt, expenseDate: exp.expenseDate || ''
        });
      });
    });

    /* 2) 모든 COMPLETED 정산의 pair별 합산 */
    var allCompletedAmt = {};
    existingList.forEach(function(s) {
      if (s.status === 'COMPLETED') {
        var k = (s.fromMemberId||0) + '_' + (s.toMemberId||0);
        allCompletedAmt[k] = (allCompletedAmt[k] || 0) + Number(s.amount || 0);
      }
    });

    /* 3) settlement 배열 (PENDING/REQUESTED 탐색용) */
    var existingByKey = {};
    existingList.forEach(function(s) {
      var key = (s.fromMemberId||0) + '_' + (s.toMemberId||0);
      if (!existingByKey[key]) existingByKey[key] = [];
      existingByKey[key].push(s);
    });

    /* 4) 내가 관련된 정산 분리 */
    var toRecv = [];
    var toSend = [];
    Object.keys(p2pMap).forEach(function(key) {
      var item = p2pMap[key];
      if (item.toMid === myMid)   toRecv.push(item);
      if (item.fromMid === myMid) toSend.push(item);
    });

    /* 지출이 없는 경우 */
    if (!toRecv.length && !toSend.length) {
      if (emptyEl) emptyEl.style.display = 'flex';
      if (recvList) recvList.innerHTML = '';
      if (sendList) sendList.innerHTML = '';
      return;
    }

    /* ── 5단계: 내가 받을 정산 렌더 ── */
    var recvHtml = '';
    var hasRecv = false;
    toRecv.forEach(function(item) {
      var key       = item.fromMid + '_' + item.toMid;
      var settleArr = existingByKey[key] || [];

      /* 핵심: 총부채 - 완료된 정산액 = 실제 남은 금액 */
      var netAmt = item.totalAmt - (allCompletedAmt[key] || 0);
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
        // ★ data-settle-id="0" → 신규 INSERT 신호
        actionBtn = '<button class="settle-action-btn settle-action-btn--request" '
          + 'data-from-mid="' + item.fromMid + '" '
          + 'data-amount="' + netAmt + '" '
          + 'data-nick="' + _esc(item.fromNick) + '" '
          + 'data-settle-id="0" '
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

      /* 핵심: 총부채 - 완료된 정산액 = 실제 남은 금액 */
      var netAmt = item.totalAmt - (allCompletedAmt[key] || 0);
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

    /* 전부 완료된 경우 (p2pMap 항목이 있지만 netAmt가 전부 0) */
    if (!hasRecv && !hasSend) {
      if (emptyEl) emptyEl.style.display = 'none';
      if (recvList) recvList.innerHTML = '';
      if (sendList) sendList.innerHTML = '<div class="settle-all-done">🎉 모든 정산이 완료됐어요!</div>';
    } else {
      if (emptyEl) emptyEl.style.display = 'none';
    }
  })
  .catch(function(err) {
    console.warn('[Settlement] 탭 로드 실패:', err);
    if (emptyEl) emptyEl.style.display = 'flex';
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
  var doneList  = document.getElementById('settleDoneList');
  var doneEmpty = document.getElementById('settleDoneEmpty');
  var myMid     = _getMyMid();
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
        if (doneEmpty) doneEmpty.style.display = 'flex';
        return;
      }

      /* batch 단위로 그룹핑 */
      var batchMap = {};
      completed.forEach(function(s) {
        var bid = s.batchId || ('single_' + s.settlementId);
        if (!batchMap[bid]) batchMap[bid] = [];
        batchMap[bid].push(s);
      });

      var html = '';
      Object.keys(batchMap).forEach(function(bid) {
        var group = batchMap[bid];
        var batchAmt = group.reduce(function(sum, s) { return sum + Number(s.amount||0); }, 0);
        var settledDate = group[0].settledAt
          ? String(group[0].settledAt).substring(0,10).replace(/-/g,'.') : '';
        var isRealBatch = !String(bid).startsWith('single_');

        var firstS     = group[0];
        var isSentByMe = Number(firstS.fromMemberId) === myMid;
        var otherNick  = isSentByMe
          ? _esc(firstS.toMemberNickname||firstS.toNickname||'?')
          : _esc(firstS.fromMemberNickname||firstS.fromNickname||'?');
        var direction  = isSentByMe ? '보냄' : '받음';
        var dirClass   = isSentByMe ? 'settle-done-dir--sent' : 'settle-done-dir--recv';

        /* 여러 transfer일 때 목록 */
        var transferHtml = '';
        if (group.length > 1) {
          transferHtml = '<div class="settle-done-transfers">'
            + group.map(function(s) {
                var sf = _esc(s.fromMemberNickname||s.fromNickname||'?');
                var st = _esc(s.toMemberNickname||s.toNickname||'?');
                return '<div class="settle-done-transfer-row">'
                  + '<span>' + sf + ' → ' + st + '</span>'
                  + '<span class="settle-done-transfer-amt">' + _fmtAmt(s.amount) + '</span>'
                  + '</div>';
              }).join('')
            + '</div>';
        }

        html += '<div class="settle-card settle-card--done">'
          + '<div class="settle-card__top">'
          +   '<div class="settle-card__avatar settle-card__avatar--done">' + String(otherNick).substring(0,2) + '</div>'
          +   '<div class="settle-card__info">'
          +     '<div class="settle-card__direction">' + (group.length > 1 ? '묶음 정산' : (isSentByMe ? '나 → ' + otherNick : otherNick + ' → 나')) + '</div>'
          +     '<div class="settle-card__hint">' + settledDate + (isRealBatch ? ' · 배치 #' + bid : ' · 단건 정산') + '</div>'
          +   '</div>'
          +   '<div class="settle-card__amt settle-card__amt--done">' + _fmtAmt(batchAmt) + '</div>'
          + '</div>'
          + transferHtml
          + '<div class="settle-card__bottom">'
          +   '<span class="settle-badge settle-badge--done">✅ 완료</span>'
          +   '<span class="settle-done-dir ' + dirClass + '">' + direction + '</span>'
          +   (isRealBatch
              ? '<button class="settle-detail-link" onclick="event.stopPropagation();openSettledBatchDetail(' + bid + ')">상세 보기 →</button>'
              : '<button class="settle-detail-link" onclick="event.stopPropagation();_openSingleSettleDetail(' + firstS.settlementId + ',\'' + otherNick + '\',' + batchAmt + ',\'' + settledDate + '\',' + (isSentByMe?'true':'false') + ')">상세 보기 →</button>'
            )
          +   '<button class="settle-del-btn" onclick="deleteSettlement(this,' + firstS.settlementId + ')" title="삭제">🗑</button>'
          + '</div>'
          + '</div>';
      });

      /* ★ Bug Fix: 항목이 있어도 이전 호출에서 표시된 빈상태가 남아있는 문제 방지
         → 항목이 있으면 반드시 명시적으로 doneEmpty를 숨긴다 */
      if (doneEmpty) doneEmpty.style.display = 'none';
      doneList.innerHTML = html;
    })
    .catch(function() {
      doneList.innerHTML = '<div class="settle-empty-msg">불러오기 실패</div>';
    });
}


/* ═══════════════════════════════════════════
   정산 액션 함수들
═══════════════════════════════════════════ */

/* 정산 요청하기
 * ★ 수정: existingSettlementId를 함께 전송 → 백엔드가 그 1건만 처리
 *         data-settle-id="0" 이면 신규 INSERT, 양수이면 그 ID만 UPDATE
 */
function requestSettlementBtn(btn) {
  var fromMid  = parseInt(btn.getAttribute('data-from-mid')) || 0;
  var amount   = parseFloat(btn.getAttribute('data-amount')) || 0;
  var nick     = btn.getAttribute('data-nick') || '?';
  var settleId = parseInt(btn.getAttribute('data-settle-id') || '0');
  if (!fromMid || !amount) { showToast('⚠️ 정산 정보가 올바르지 않아요'); return; }
  btn.disabled = true; btn.textContent = '요청 중...';

  fetch(CTX_PATH + '/api/trips/' + TRIP_ID + '/settlements/request', {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify({
      fromMemberId: fromMid,
      amount: amount,
      existingSettlementId: settleId > 0 ? settleId : null   // ★ 단건 ID 전달
    })
  })
  .then(function(r) { return r.ok ? r.json() : Promise.reject(r.status); })
  .then(function(data) {
    if (data.success) {
      showToast('📬 ' + nick + '님에게 정산을 요청했어요!');
      _loadSettleStatusView();
      _renderSettleStatusChip();
      /* ★ 알림 발송 */
      fetch(CTX_PATH + '/api/notification/send', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ tripId: TRIP_ID, receiverId: fromMid,
          message: '정산 요청이 도착했어요! 가계부를 확인해주세요.', type: 'EXPENSE' })
      }).catch(function() {});
    } else {
      showToast('⚠️ ' + (data.message || '요청 실패'));
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
      /* ★ settlements 목록 갱신 후 정산탭 재계산 (completedPairs 갱신 필요) */
      _loadSettleTab();
      _loadHomeTab();
    } else {
      btn.disabled = false;
      btn.textContent = '✅ 정산 완료 처리';
      showToast('⚠️ 처리에 실패했어요');
    }
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
   단건 정산 상세 모달 — 관련 지출 포함
═══════════════════════════════════════════ */
function _openSingleSettleDetail(settlementId, otherNick, amount, settledDate, isSentByMe) {
  var modal   = document.getElementById('settleDetailModal');
  var body    = document.getElementById('settleDetailBody');
  var titleEl = modal && modal.querySelector('.modal-box__title');
  if (!body) return;
  if (titleEl) titleEl.textContent = '✅ 정산 완료 상세';

  body.innerHTML = '<div style="text-align:center;padding:40px;color:var(--light);">불러오는 중...</div>';
  openModal('settleDetailModal');

  var dirText  = isSentByMe ? ('나 → ' + otherNick) : (otherNick + ' → 나');
  var dirColor = isSentByMe ? '#C53030' : '#276749';

  /* 두 당사자 사이 관련 지출 조회 */
  fetch(CTX_PATH + '/api/trips/' + TRIP_ID + '/expenses/with-participants')
    .then(function(r) { return r.ok ? r.json() : []; })
    .then(function(expenses) {
      var myMid = _getMyMid();
      /* 정산 방향으로 당사자 특정:
         isSentByMe=true → 내가 fromMid(돈 보내는 쪽), otherNick이 toMid(받는 쪽=결제자)
         isSentByMe=false → 내가 toMid(결제자), otherNick이 fromMid */
      var relatedExp = (expenses || []).filter(function(exp) {
        var payerId = Number(exp.payerId);
        var parts   = (exp.participants || []).map(function(p) { return Number(p.memberId); });
        if (isSentByMe) {
          /* 상대방이 결제자 + 내가 참여자 */
          return parts.indexOf(myMid) !== -1;
        } else {
          /* 내가 결제자 + 상대방이 참여자 */
          var memberIds = (exp.participants || []).map(function(p) {
            return String(p.memberNickname || p.nickname || '');
          });
          var nickMatch = memberIds.some(function(n) {
            return n === otherNick || n.indexOf(otherNick) !== -1;
          });
          return payerId === myMid && nickMatch;
        }
      }).slice(0, 10);

      var summaryHtml =
        '<div class="bd-section bd-summary">'
        + '<div class="bd-section-label">정산 요약</div>'
        + '<div class="bd-transfer-row">'
        +   '<div class="bd-transfer-avatars">'
        +     '<div class="bd-avatar" style="background:' + (isSentByMe ? 'linear-gradient(135deg,#FC8181,#FEB2B2)' : 'linear-gradient(135deg,#89CFF0,#C2B8D9)') + ';">'
        +       (isSentByMe ? '나' : String(otherNick).substring(0,2))
        +     '</div>'
        +     '<div class="bd-arrow">→</div>'
        +     '<div class="bd-avatar bd-avatar--recv">' + (isSentByMe ? String(otherNick).substring(0,2) : '나') + '</div>'
        +   '</div>'
        +   '<div class="bd-transfer-info">'
        +     '<div class="bd-transfer-names" style="color:' + dirColor + ';font-weight:800;">' + dirText + '</div>'
        +     '<div class="bd-transfer-amt">' + _fmtAmt(amount) + '</div>'
        +   '</div>'
        + '</div>'
        + '<div class="bd-summary-footer">'
        +   '<div class="bd-total-row"><span>정산 금액</span><span class="bd-total-amt">' + _fmtAmt(amount) + '</span></div>'
        +   '<div class="bd-status-row"><span class="bd-badge-done">✅ 완료</span><span class="bd-settled-date">' + (settledDate || '') + '</span></div>'
        + '</div>'
        + '</div>';

      var expHtml = '<div class="bd-section"><div class="bd-section-label">관련 지출 내역</div>';
      if (!relatedExp.length) {
        expHtml += '<div style="padding:16px;text-align:center;color:var(--light);font-size:13px;">관련 지출을 찾을 수 없어요</div>';
      } else {
        relatedExp.forEach(function(exp) {
          var m    = _cat(exp.category);
          var date = exp.expenseDate ? String(exp.expenseDate).substring(5).replace(/-/g,'/') : '';
          var myShare = 0;
          (exp.participants || []).forEach(function(p) {
            if (Number(p.memberId) === myMid) myShare = Number(p.shareAmount || 0);
          });
          expHtml +=
            '<div class="bd-exp-card" onclick="openExpenseDetail(' + exp.expenseId + ')" style="cursor:pointer;">'
            + '<div class="bd-exp-card__header">'
            +   '<div class="bd-exp-icon" style="background:' + m.light + ';color:' + m.color + ';">' + m.icon + '</div>'
            +   '<div class="bd-exp-info">'
            +     '<div class="bd-exp-name">' + _esc(exp.description || '') + '</div>'
            +     '<div class="bd-exp-meta">' + m.name + ' · ' + date + ' · 총 ' + _fmtAmt(exp.amount) + '</div>'
            +   '</div>'
            +   '<div class="bd-exp-payer">'
            +     (myShare > 0
                  ? '<span style="font-weight:800;color:#2D3748;">내 몫 ' + _fmtAmt(myShare) + '</span>'
                  : '👤 ' + _esc(exp.payerNickname || '?'))
            +   '</div>'
            + '</div>'
            + '</div>';
        });
      }
      expHtml += '</div>';

      body.innerHTML = summaryHtml + expHtml;
    })
    .catch(function() {
      body.innerHTML = '<div style="padding:24px;text-align:center;color:var(--light);font-size:13px;">정보를 불러오지 못했어요</div>';
    });
}


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

	  /* 결제 수단 뱃지 만들기 */
      var payType = e.paymentType || 'NONE';
      var payBadgeHtml = '';
      if (payType === 'CARD') payBadgeHtml = '<span class="pay-badge CARD">💳 카드</span>';
      else if (payType === 'CASH') payBadgeHtml = '<span class="pay-badge CASH">💵 현금</span>';
      else payBadgeHtml = '<span class="pay-badge NONE">➖ 미선택</span>';

      /* ── 기본 정보 그리드 ── */
      html += '<div class="ed-info-grid">'
        + _edInfoItem('📅', '날짜', date)
        + _edInfoItem(m.icon, '카테고리', m.name)
        + _edInfoItem('👤', '결제자', _esc(e.payerNickname||'?'))
        + _edInfoItem('💳', '결제 수단', payBadgeHtml) /* ← 여기 적용! */
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
      _resetExpenseForm();   /* ★ 참여자/결제자/날짜 전체 초기화 */
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
  /* ★ 수정: 매번 새로 구성 (호출 전에 _wsParticipants=[] 로 초기화됨)
     나 자신(MY_MEMBER_ID)이 포함되도록 보장
     is-me 클래스나 data-is-me 속성으로 구분 */
  var myMid = _getMyMid();
  var found = {};
  document.querySelectorAll('#expPayerMenu .exp-payer-option').forEach(function(opt) {
    var id   = parseInt(opt.getAttribute('data-id'));
    var nick = opt.querySelector('.exp-payer-option__name');
    if (!id || !nick) return;
    if (found[id]) return;   /* 중복 방지 */
    found[id] = true;
    var nickText = nick.textContent.trim()
      .replace(/\s*\(나\)\s*$/, '')   /* "(나)" 접미사 제거 */
      .trim();
    _wsParticipants.push({ id: id, nick: nickText, checked: true, isMe: (id === myMid) });
  });

  /* 혹시 내가 목록에 없으면 (렌더 타이밍 문제) MEMBER_DICT에서 보완 */
  if (myMid && !found[myMid] && typeof MEMBER_DICT !== 'undefined' && MEMBER_DICT[myMid]) {
    _wsParticipants.unshift({ id: myMid, nick: MEMBER_DICT[myMid], checked: true, isMe: true });
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
  ['exp-name','exp-amt','exp-memo'].forEach(function(id) { var el = document.getElementById(id); if (el) el.value = ''; });
  var pmtEl = document.getElementById('exp-payment-type'); if (pmtEl) pmtEl.value = '';
  var menu = document.getElementById('expPayerMenu'), btn = document.getElementById('expPayerBtn');
  if (menu) menu.classList.remove('open');
  if (btn)  btn.classList.remove('open');

  /* ★ 수정: 결제자를 나로 초기화 */
  var myMid = _getMyMid();
  var myOpt = myMid
    ? document.querySelector('#expPayerMenu .exp-payer-option[data-id="' + myMid + '"]')
    : null;
  var firstOpt = myOpt || document.querySelector('.exp-payer-option');
  if (firstOpt) {
    var fid   = parseInt(firstOpt.getAttribute('data-id'));
    var fnick = firstOpt.querySelector('.exp-payer-option__name');
    selectPayer(fid, fnick ? fnick.textContent.replace('(나)', '').trim() : '나', !!myOpt);
  }

  /* ★ 수정: 분담자 목록 재초기화 */
  _wsParticipants = [];
  _extraParticipants = [];
  _extraIdCounter = 0;
  _initParticipants();

  document.querySelectorAll('#exp-participants input[type=checkbox]').forEach(function(cb) { cb.checked = true; });
  var ri = document.getElementById('exp-receipt'); if (ri) ri.value = '';
  var rp = document.getElementById('exp-receipt-preview'); if (rp) { rp.innerHTML = ''; rp.style.display = 'none'; }

  /* 날짜도 오늘로 재설정 */
  var expDateEl = document.getElementById('exp-date');
  if (expDateEl) {
    var today = new Date();
    expDateEl.value = today.getFullYear() + '-'
      + String(today.getMonth() + 1).padStart(2, '0') + '-'
      + String(today.getDate()).padStart(2, '0');
  }
  recalcSharePreview();
}

function deleteExpenseItem(expenseId, event) {
  if (event) event.stopPropagation();

  if (!confirm('이 지출을 삭제할까요?')) return;
  
  if(window.isDeleting) return;
  window.isDeleting = true;

  fetch(CTX_PATH + '/api/expenses/' + expenseId, { method: 'DELETE' })
    .then(function(r) {
      if (r.ok || r.status === 204) {
        showToast('🗑️ 지출이 삭제됐어요');
        if (typeof closeModal === 'function') closeModal('expenseDetailModal');
        loadExpenseList();
        _loadHomeTab();
      } else {
        showToast('⚠️ 이미 삭제되었거나 실패했어요');
      }
    })
    .catch(function() { showToast('⚠️ 삭제 에러 발생'); })
    .finally(function() { window.isDeleting = false; });
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

  /* ★ 수정: 결제자 초기화 — selected 옵션 기준으로 설정
     DOMContentLoaded 시점에 .selected 클래스가 없을 수 있으므로
     첫 번째 옵션을 fallback으로 사용 */
  var firstSelected = document.querySelector('.exp-payer-option.selected')
                   || document.querySelector('.exp-payer-option');
  if (firstSelected) {
    var fid   = parseInt(firstSelected.getAttribute('data-id'));
    var fnick = firstSelected.querySelector('.exp-payer-option__name');
    var fisMe = firstSelected.classList.contains('is-me');
    if (fnick) selectPayer(fid, fnick.textContent.trim(), fisMe);
  }

  /* ★ 수정: 지출 추가 모달 열릴 때마다 참여자 목록 재초기화
     기존: _wsParticipants.length===0 일 때만 초기화 → 모달 재열기 시 누락 버그
     수정: 매번 _wsParticipants를 새로 구성 */
  document.addEventListener('click', function(e) {
    var tgt = e.target;
    /* 버튼 자체 또는 버튼 내 자식 요소 클릭 모두 처리 */
    var isAddBtn = tgt && (
      (tgt.getAttribute && tgt.getAttribute('onclick') === "openModal('addExpenseModal')") ||
      (tgt.closest && tgt.closest('[onclick]') && tgt.closest('[onclick]').getAttribute('onclick') === "openModal('addExpenseModal')")
    );
    if (isAddBtn) {
      setTimeout(function() {
        /* 매번 새로 구성 — 외부 인원(_extraParticipants)은 유지 */
        _wsParticipants = [];
        _initParticipants();
        _initCatChipDrag();
      }, 80);
    }
  });

  var expDateEl = document.getElementById('exp-date');
  if (expDateEl && !expDateEl.value) {
    var today = new Date();
    expDateEl.value = today.getFullYear() + '-'
      + String(today.getMonth() + 1).padStart(2, '0') + '-'
      + String(today.getDate()).padStart(2, '0');
  }
  var amtEl = document.getElementById('exp-amt');
  if (amtEl) amtEl.addEventListener('input', recalcSharePreview);
  _initCatChipDrag();

  document.addEventListener('input', function(e) {
    if (e.target && (e.target.id === 'exp-amt' || e.target.id === 'exp-name')) {
      _renderSplitList();
      _updateSubmitBtn();
    }
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


/* ═══════════════════════════════════════════
   정산 완료 batch 상세보기
   GET /api/trips/{tripId}/settlements/batch/{batchId}/detail
═══════════════════════════════════════════ */
function openSettledBatchDetail(batchId) {
  var modal = document.getElementById('settleDetailModal');
  var body  = document.getElementById('settleDetailBody');
  var titleEl = modal && modal.querySelector('.modal-box__title');
  if (!body) return;

  if (titleEl) titleEl.textContent = '📊 정산 완료 상세';
  body.innerHTML = '<div style="text-align:center;padding:40px;color:var(--light);">불러오는 중...</div>';
  openModal('settleDetailModal');

  fetch(CTX_PATH + '/api/trips/' + TRIP_ID + '/settlements/batch/' + batchId + '/detail')
    .then(function(r) { return r.ok ? r.json() : Promise.reject(r.status); })
    .then(function(data) {
      body.innerHTML =
        _renderBatchSummary(data)
        + _renderBatchCalcReason(data)
        + _renderBatchExpenses(data);
    })
    .catch(function(err) {
      body.innerHTML = '<div style="text-align:center;padding:24px;color:var(--light);font-size:13px;">상세 정보를 불러오지 못했어요 (' + err + ')</div>';
    });
}

/* ── 섹션 1: 정산 요약 ── */
function _renderBatchSummary(data) {
  var transfers   = data.transfers || [];
  var settledDate = data.settledAt
    ? String(data.settledAt).substring(0,16).replace('T',' ') : '';
  var totalAmt = _fmtAmt(data.totalAmount || 0);

  var transferRows = transfers.map(function(t) {
    var fn = _esc(t.fromMemberNickname||t.fromNickname||'?');
    var tn = _esc(t.toMemberNickname||t.toNickname||'?');
    return '<div class="bd-transfer-row">'
      + '<div class="bd-transfer-avatars">'
      +   '<div class="bd-avatar">' + fn.substring(0,2) + '</div>'
      +   '<div class="bd-arrow">→</div>'
      +   '<div class="bd-avatar bd-avatar--recv">' + tn.substring(0,2) + '</div>'
      + '</div>'
      + '<div class="bd-transfer-info">'
      +   '<div class="bd-transfer-names">' + fn + ' → ' + tn + '</div>'
      +   '<div class="bd-transfer-amt">' + _fmtAmt(t.amount) + '</div>'
      + '</div>'
      + '</div>';
  }).join('');

  return '<div class="bd-section bd-summary">'
    + '<div class="bd-section-label">정산 요약</div>'
    + transferRows
    + '<div class="bd-summary-footer">'
    +   '<div class="bd-total-row"><span>총 정산 금액</span><span class="bd-total-amt">' + totalAmt + '</span></div>'
    +   '<div class="bd-status-row"><span class="bd-badge-done">✅ 완료</span><span class="bd-settled-date">' + settledDate + '</span></div>'
    + '</div>'
    + '</div>';
}

/* ── 섹션 2: 계산 근거 ── */
function _renderBatchCalcReason(data) {
  var members = data.memberSummary || [];
  if (!members.length) return '';

  var rows = members.map(function(m) {
    var bal     = Number(m.balance || 0);
    var paid    = Number(m.shareAmount || 0);  // shareAmount를 부담액으로
    var balHtml = bal > 0
      ? '<span class="bd-bal-recv">💚 +' + _fmtAmt(bal) + ' 받을 돈</span>'
      : bal < 0
      ? '<span class="bd-bal-send">💸 ' + _fmtAmt(bal) + ' 보낼 돈</span>'
      : '<span class="bd-bal-zero">± 0</span>';

    return '<div class="bd-member-row">'
      + '<div class="bd-member-nick">' + _esc(m.nickname||'?') + '</div>'
      + '<div class="bd-member-share">' + _fmtAmt(paid) + ' 부담</div>'
      + '<div class="bd-member-bal">' + balHtml + '</div>'
      + '</div>';
  }).join('');

  return '<div class="bd-section">'
    + '<div class="bd-section-label">계산 근거</div>'
    + '<div class="bd-member-header">'
    +   '<span>멤버</span><span>부담액</span><span>잔액</span>'
    + '</div>'
    + rows
    + '</div>';
}

/* ── 섹션 3: 포함된 지출 목록 ── */
function _renderBatchExpenses(data) {
  var expenses = data.expenses || [];
  if (!expenses.length) {
    return '<div class="bd-section"><div class="bd-section-label">포함된 지출</div>'
      + '<div style="padding:16px;text-align:center;color:var(--light);font-size:13px;">지출 내역을 불러올 수 없어요</div></div>';
  }

  var cards = expenses.map(function(e) {
    var m    = _cat(e.category);
    var date = e.expenseDate ? String(e.expenseDate).substring(5).replace(/-/g,'/') : '';
    var parts = (e.participants||[]);

    /* 분담자 표시: 최대 3명 인라인, 초과 시 +N명 */
    var partHtml = '';
    if (parts.length) {
      var shown = parts.slice(0, 3).map(function(p) {
        var nick = p.memberNickname || p.nickname || '?';
        return '<span class="bd-part-chip">' + _esc(nick) + ' ' + _fmtAmt(p.shareAmount) + '</span>';
      }).join('');
      var more = parts.length > 3 ? '<span class="bd-part-more">+' + (parts.length-3) + '명</span>' : '';
      partHtml = '<div class="bd-part-list">' + shown + more + '</div>';
    }

    var hasReceipt = !!(e.receiptUrl && String(e.receiptUrl).trim());

    return '<div class="bd-exp-card">'
      + '<div class="bd-exp-card__header">'
      +   '<div class="bd-exp-icon" style="background:' + m.light + ';color:' + m.color + ';">' + m.icon + '</div>'
      +   '<div class="bd-exp-info">'
      +     '<div class="bd-exp-name">' + _esc(e.description||'') + '</div>'
      +     '<div class="bd-exp-meta">' + m.name + ' · ' + date + ' · ' + _fmtAmt(e.amount) + '</div>'
      +   '</div>'
      +   '<div class="bd-exp-payer">👤 ' + _esc(e.payerNickname||'?') + '</div>'
      + '</div>'
      + partHtml
      + (hasReceipt
         ? '<div class="bd-exp-receipt"><button class="bd-receipt-btn" onclick="openImageViewer(\'' + _esc(e.receiptUrl) + '\')">📷 영수증 보기</button></div>'
         : '')
      + '</div>';
  }).join('');

  return '<div class="bd-section">'
    + '<div class="bd-section-label">포함된 지출 (' + expenses.length + '건)</div>'
    + cards
    + '</div>';
}
