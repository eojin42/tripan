/**
 * workspace.expense.js
 * ──────────────────────────────────────────────
 * 담당: 가계부 · 정산 CRUD + 내부 3탭 (홈 / 내역 / 정산)
 * 의존: workspace.ui.js (showToast, openModal, closeModal, normalizeRow)
 *       TRIP_ID, CTX_PATH, MY_MEMBER_ID, MEMBER_DICT
 *
 * API 매핑
 *  홈  탭  ← GET  /api/trips/{id}/expenses/summary
 *  내역 탭 ← GET  /api/trips/{id}/expenses?page=1&size=50
 *  정산 탭 ← GET  /api/trips/{id}/settlements/preview
 *           ← GET  /api/trips/{id}/settlements          (정산 완료 내역)
 *           ← POST /api/trips/{id}/settlements          (확정)
 *           ← PATCH /api/settlements/complete           (송금 완료)
 *  삭제    ← DELETE /api/expenses/{expenseId}
 *  추가    ← POST /api/trips/{id}/expenses
 * ──────────────────────────────────────────────
 */

/* ═══════════════════════════════════════════
   카테고리 메타데이터
═══════════════════════════════════════════ */
var _CAT_ICON = {
  FOOD: '🍽️', ACCOMMODATION: '🏨', TRANSPORT: '🚗',
  TOUR: '🎯', CAFE: '☕', SHOPPING: '🛍️', ETC: '📦'
};
var _CAT_NAME = {
  FOOD: '식비', ACCOMMODATION: '숙소', TRANSPORT: '교통',
  TOUR: '관광', CAFE: '카페', SHOPPING: '쇼핑', ETC: '기타'
};
var _CAT_COLOR = {
  FOOD:          'linear-gradient(135deg,#FFB6C1,#FFCDD5)',
  ACCOMMODATION: 'linear-gradient(135deg,#89CFF0,#B5D8F7)',
  TRANSPORT:     'linear-gradient(135deg,#C2B8D9,#D9C8E8)',
  TOUR:          'linear-gradient(135deg,#A8C8E1,#BFD9ED)',
  CAFE:          'linear-gradient(135deg,#F6C9A0,#FADA9C)',
  SHOPPING:      'linear-gradient(135deg,#A8E6CF,#B5EDD6)',
  ETC:           'linear-gradient(135deg,#D5D8DC,#E8EAED)'
};
var _CAT_ORDER = ['FOOD', 'TRANSPORT', 'ACCOMMODATION', 'TOUR', 'CAFE', 'SHOPPING', 'ETC'];

/* ═══════════════════════════════════════════
   내부 탭 전환
   탭ID: home | list | settle
═══════════════════════════════════════════ */
function switchExpTab(name, btn) {
  /* 모든 pane 숨김 */
  document.querySelectorAll('.exp-tab-pane').forEach(function(p) {
    p.style.display = 'none';
  });
  /* 모든 탭버튼 비활성 */
  document.querySelectorAll('.exp-itab').forEach(function(b) {
    b.style.color            = 'var(--light)';
    b.style.borderBottom     = '2px solid transparent';
    b.style.fontWeight       = '700';
    b.style.backgroundColor  = 'transparent';
  });

  /* 선택 pane 표시 */
  var pane = document.getElementById('exp-tab-' + name);
  if (pane) { pane.style.display = 'flex'; pane.style.flexDirection = 'column'; }

  /* 선택 탭버튼 활성 */
  if (btn) {
    btn.style.color        = '#2D3748';
    btn.style.borderBottom = '2.5px solid #89CFF0';
    btn.style.fontWeight   = '800';
  }

  /* 탭별 데이터 로드 (최초 1회 또는 매번) */
  if (name === 'home')   _loadHomeTab();
  if (name === 'list')   loadExpenseList();
  if (name === 'settle') _loadSettleTab();
}

/* ═══════════════════════════════════════════
   ① 홈 탭 — 통계 대시보드
   GET /api/trips/{tripId}/expenses/summary
   response: { tripId, totalAmount,
               categoryBreakdown: [{category, totalAmount}],
               memberPayments:    [{memberId, nickname, paidAmount}],
               memberShares:      [{memberId, nickname, shareAmount, balance}] }
═══════════════════════════════════════════ */
function _loadHomeTab() {
  fetch(CTX_PATH + '/api/trips/' + TRIP_ID + '/expenses/summary')
    .then(function(r) { return r.ok ? r.json() : Promise.reject(r.status); })
    .then(function(data) {
      var total = Number(data.totalAmount || 0);

      /* ── 총액 ── */
      var amtEl = document.getElementById('summaryAmt');
      if (amtEl) amtEl.textContent = '₩ ' + total.toLocaleString();

      /* ── 나의 결제 / 부담 / 잔액 ── */
      var myMid  = typeof MY_MEMBER_ID !== 'undefined' ? Number(MY_MEMBER_ID) : 0;
      var myPaid = 0, myShare = 0;

      if (data.memberPayments) {
        data.memberPayments.forEach(function(p) {
          if (Number(p.memberId) === myMid) myPaid = Number(p.paidAmount || 0);
        });
      }
      if (data.memberShares) {
        data.memberShares.forEach(function(s) {
          if (Number(s.memberId) === myMid) myShare = Number(s.shareAmount || 0);
        });
      }

      var el = document.getElementById('myPaidAmt');
      if (el) el.textContent = '₩ ' + myPaid.toLocaleString();

      el = document.getElementById('myShareAmt');
      if (el) el.textContent = '₩ ' + myShare.toLocaleString();

      /* ── 나의 잔액 상태 ── */
      var myBalEl = document.getElementById('myBalanceLine');
      if (myBalEl && data.memberShares) {
        var myShareEntry = data.memberShares.find(function(s) { return Number(s.memberId) === myMid; });
        if (myShareEntry) {
          var bal = Number(myShareEntry.balance || 0);
          if (bal > 0) {
            myBalEl.innerHTML = '<span class="exp-home-balance-chip exp-home-balance-chip--recv">💚 ₩ ' + bal.toLocaleString() + ' 받을 예정</span>';
          } else if (bal < 0) {
            myBalEl.innerHTML = '<span class="exp-home-balance-chip exp-home-balance-chip--send">💸 ₩ ' + Math.abs(bal).toLocaleString() + ' 보낼 예정</span>';
          } else {
            myBalEl.innerHTML = '<span class="exp-home-balance-chip exp-home-balance-chip--done">✅ 정산 없음</span>';
          }
        }
      }

      /* ── 카테고리 카드 ── */
      _renderCatsFromSummary(data.categoryBreakdown || [], total);

      /* ── 내 지출 요약 (로그인 유저만) ── */
      _renderMyExpenseSummary(myPaid, myShare, data.memberShares || [], myMid);

      /* ── 정산 대기 현황 칩 (나한테 온 정산 요청) ── */
      _renderSettleStatusChip();
    })
    .catch(function(err) {
      console.warn('[Expense] 홈 탭 로드 실패:', err);
      /* 지출 없을 때도 graceful — 0원으로 유지 */
    });
}

/* 카테고리 카드 렌더 (summary API 기반) */
function _renderCatsFromSummary(breakdown, total) {
  var catsSection = document.getElementById('expenseCatsSection');
  var catsEl      = document.getElementById('expenseCats');
  if (!catsEl) return;

  var filtered = (breakdown || []).filter(function(c) { return Number(c.totalAmount || 0) > 0; });

  if (!filtered.length) {
    if (catsSection) catsSection.style.display = 'none';
    return;
  }
  if (catsSection) catsSection.style.display = '';

  var maxAmt = Math.max.apply(null, filtered.map(function(c) { return Number(c.totalAmount); })) || 1;

  /* _CAT_ORDER 순서대로 정렬 후 렌더 */
  var ordered = _CAT_ORDER
    .map(function(k) {
      return filtered.find(function(c) { return (c.category || '').toUpperCase() === k; });
    })
    .filter(Boolean);

  /* 존재하지만 _CAT_ORDER에 없는 카테고리도 추가 */
  filtered.forEach(function(c) {
    var k = (c.category || 'ETC').toUpperCase();
    if (_CAT_ORDER.indexOf(k) === -1) ordered.push(c);
  });

  catsEl.innerHTML = ordered.map(function(c) {
    var k   = (c.category || 'ETC').toUpperCase();
    var amt = Number(c.totalAmount || 0);
    var pct = total > 0 ? Math.round(amt / total * 100) : 0;
    var bar = Math.round(amt / maxAmt * 100);
    var bg  = _CAT_COLOR[k] || _CAT_COLOR.ETC;
    var pctText = pct + '%';
    return '<div class="expense-cat" onclick="openCatDetail(\'' + k + '\')">'
      + '<div class="expense-cat__row">'
      +   '<span class="expense-cat__icon">' + (_CAT_ICON[k] || '📦') + '</span>'
      +   '<span class="expense-cat__name">' + (_CAT_NAME[k] || k) + '</span>'
      +   '<span class="expense-cat__pct">' + pctText + '</span>'
      +   '<span class="expense-cat__amt">₩ ' + amt.toLocaleString() + '</span>'
      + '</div>'
      + '<div class="expense-cat__bar">'
      +   '<div class="expense-cat__bar-fill" style="width:' + bar + '%;background:' + bg + ';"></div>'
      + '</div>'
      + '</div>';
  }).join('');
}

/* 내 지출 요약 (홈탭 — 로그인한 유저 기준만) */
function _renderMyExpenseSummary(myPaid, myShare, memberShares, myMid) {
  var el = document.getElementById('expMemberBalance');
  if (!el) return;

  var myEntry = memberShares.find(function(s) { return Number(s.memberId) === myMid; });
  var bal = myEntry ? Number(myEntry.balance || 0) : (myPaid - myShare);

  var balHtml, balColor;
  if (bal > 0) {
    balHtml  = '💚 ₩ ' + Math.abs(bal).toLocaleString() + ' 받을 예정';
    balColor = '#276749';
  } else if (bal < 0) {
    balHtml  = '💸 ₩ ' + Math.abs(bal).toLocaleString() + ' 보낼 예정';
    balColor = '#C53030';
  } else {
    balHtml  = '✅ 정산 없음';
    balColor = '#718096';
  }

  el.innerHTML = '<div class="exp-home-section-title">이번 여행 내 지출 요약</div>'
    + '<div class="exp-my-summary-card">'
    +   '<div class="exp-my-summary-row">'
    +     '<span class="exp-my-summary-label">내가 결제한 총액</span>'
    +     '<span class="exp-my-summary-val">₩ ' + myPaid.toLocaleString() + '</span>'
    +   '</div>'
    +   '<div class="exp-my-summary-row">'
    +     '<span class="exp-my-summary-label">내가 부담해야 할 금액</span>'
    +     '<span class="exp-my-summary-val">₩ ' + myShare.toLocaleString() + '</span>'
    +   '</div>'
    +   '<div class="exp-my-summary-divider"></div>'
    +   '<div class="exp-my-summary-row exp-my-summary-row--result">'
    +     '<span class="exp-my-summary-label">정산 결과</span>'
    +     '<span class="exp-my-summary-result" style="color:' + balColor + ';">' + balHtml + '</span>'
    +   '</div>'
    + '</div>'
    + '<button class="exp-my-detail-btn" onclick="openMyExpenseDetail()">내 지출 상세 보기 →</button>';
}

/* 내 지출 상세 모달 */
function openMyExpenseDetail() {
  var body  = document.getElementById('memberSettleBody');
  var title = document.getElementById('memberSettleTitle');
  if (!body || !title) return;

  var myMid = typeof MY_MEMBER_ID !== 'undefined' ? Number(MY_MEMBER_ID) : -1;
  title.textContent = '내 지출 내역';
  body.innerHTML = '<div style="text-align:center;padding:20px;color:var(--light);">불러오는 중...</div>';
  openModal('memberSettleModal');

  fetch(CTX_PATH + '/api/trips/' + TRIP_ID + '/expenses?page=1&size=200')
    .then(function(r) { return r.ok ? r.json() : Promise.reject(r.status); })
    .then(function(list) {
      list = (list || []).map(normalizeRow);

      /* 내가 결제한 지출 */
      var paidList   = list.filter(function(e) { return Number(e.payerId) === myMid; });
      /* 내가 분담한 지출 (타인 결제 포함) */
      /* SummaryResponse에는 participant 목록 없으므로 분담은 별도 추정 불가 → 전체 표시 */
      var paidTotal  = paidList.reduce(function(s, e) { return s + Number(e.amount || 0); }, 0);
      var totalCount = list.length;

      var html = '<div class="ms-stat-bar">'
        + '<div class="ms-stat"><div class="ms-stat-label">내 결제</div><div class="ms-stat-val">₩ ' + paidTotal.toLocaleString() + '</div></div>'
        + '<div class="ms-stat"><div class="ms-stat-label">참여 지출</div><div class="ms-stat-val">' + totalCount + '건</div></div>'
        + '</div>';

      if (paidList.length) {
        html += '<div class="ms-section-head">💳 내가 결제한 지출</div>';
        html += paidList.map(function(e) {
          var date = e.expenseDate ? String(e.expenseDate).substring(5).replace(/-/g, '/') : '';
          var k = (e.category || 'ETC').toUpperCase();
          return '<div class="ms-expense-item" onclick="closeModal(\'memberSettleModal\');openExpenseDetail(' + e.expenseId + ')">'
            + '<span class="ms-cat-icon">' + (_CAT_ICON[k] || '📦') + '</span>'
            + '<div class="ms-item-info"><div class="ms-item-name">' + _esc(e.description || '') + '</div>'
            + '<div class="ms-item-date">' + date + '</div></div>'
            + '<div class="ms-item-amt">₩ ' + Number(e.amount || 0).toLocaleString() + '</div>'
            + '</div>';
        }).join('');
      }

      if (!paidList.length) {
        html += '<div style="text-align:center;padding:20px;color:var(--light);font-size:13px;">아직 결제한 지출이 없어요</div>';
      }

      body.innerHTML = html;
    })
    .catch(function() {
      body.innerHTML = '<div style="text-align:center;padding:20px;color:var(--light);">불러오기 실패</div>';
    });
}


/* ═══════════════════════════════════════════
   멤버 정산 상세 모달 — 이 멤버의 결제별 정산 내역
═══════════════════════════════════════════ */
function openMemberSettleDetail(memberId, nickname) {
  var body  = document.getElementById('memberSettleBody');
  var title = document.getElementById('memberSettleTitle');
  if (!body || !title) return;

  title.textContent = nickname + '님의 정산 현황';
  body.innerHTML = '<div style="text-align:center;padding:20px;color:var(--light);">불러오는 중...</div>';
  openModal('memberSettleModal');

  /* 지출 목록 가져와서 이 멤버가 결제한 것과 분담한 것 분리 */
  fetch(CTX_PATH + '/api/trips/' + TRIP_ID + '/expenses?page=1&size=200')
    .then(function(r) { return r.ok ? r.json() : Promise.reject(r.status); })
    .then(function(list) {
      list = (list || []).map(normalizeRow);
      var mid = Number(memberId);

      /* 이 멤버가 결제한 지출 */
      var paidList = list.filter(function(e) { return Number(e.payerId) === mid; });
      /* 이 멤버가 분담(참여)한 지출 */
      var sharedList = list.filter(function(e) { return Number(e.payerId) !== mid; });

      var paidTotal   = paidList.reduce(function(s, e) { return s + Number(e.amount || 0); }, 0);

      var html = '';

      if (paidList.length) {
        html += '<div class="ms-section-head">💳 ' + _esc(nickname) + '님이 결제한 지출</div>';
        html += '<div class="ms-section-total">총 ₩ ' + paidTotal.toLocaleString() + ' 결제</div>';
        html += paidList.map(function(e) {
          var date = e.expenseDate ? String(e.expenseDate).substring(5).replace(/-/g, '/') : '';
          var k = (e.category || 'ETC').toUpperCase();
          return '<div class="ms-expense-item" onclick="closeModal(\'memberSettleModal\');openExpenseDetail(' + e.expenseId + ')">'
            + '<span class="ms-cat-icon">' + (_CAT_ICON[k] || '📦') + '</span>'
            + '<div class="ms-item-info">'
            +   '<div class="ms-item-name">' + _esc(e.description || '') + '</div>'
            +   '<div class="ms-item-date">' + date + '</div>'
            + '</div>'
            + '<div class="ms-item-amt">₩ ' + Number(e.amount || 0).toLocaleString() + '</div>'
            + '</div>';
        }).join('');
      }

      if (sharedList.length) {
        html += '<div class="ms-section-head" style="margin-top:14px;">🤝 참여한 공동 지출</div>';
        html += sharedList.map(function(e) {
          var date = e.expenseDate ? String(e.expenseDate).substring(5).replace(/-/g, '/') : '';
          var k = (e.category || 'ETC').toUpperCase();
          return '<div class="ms-expense-item" onclick="closeModal(\'memberSettleModal\');openExpenseDetail(' + e.expenseId + ')">'
            + '<span class="ms-cat-icon">' + (_CAT_ICON[k] || '📦') + '</span>'
            + '<div class="ms-item-info">'
            +   '<div class="ms-item-name">' + _esc(e.description || '') + '</div>'
            +   '<div class="ms-item-date">' + date + ' · 결제: ' + _esc(e.payerNickname || '?') + '</div>'
            + '</div>'
            + '<div class="ms-item-amt">분담 중</div>'
            + '</div>';
        }).join('');
      }

      if (!paidList.length && !sharedList.length) {
        html = '<div style="text-align:center;padding:24px;color:var(--light);font-size:13px;">관련 지출이 없어요</div>';
      }

      body.innerHTML = html;
    })
    .catch(function() {
      body.innerHTML = '<div style="text-align:center;padding:20px;color:var(--light);">불러오기 실패</div>';
    });
}


/* 정산 대기 현황 칩 */
function _renderSettleStatusChip() {
  var el = document.getElementById('expSettleStatus');
  if (!el) return;

  /* 나한테 온 정산 요청 (toMemberId = 나) */
  var _myChipId = typeof MY_MEMBER_ID !== 'undefined' ? Number(MY_MEMBER_ID) : 0;
  var _sChipUrl = CTX_PATH + '/api/trips/' + TRIP_ID + '/settlements' + (_myChipId ? '?memberId=' + _myChipId : '');
  fetch(_sChipUrl)
    .then(function(r) { return r.ok ? r.json() : null; })
    .then(function(data) {
      var list = data && data.settlements ? data.settlements : [];
      /* 나한테 온 정산 요청 = toMemberId가 나 + PENDING 상태 */
      var incoming = list.filter(function(s) {
        return s.status === 'PENDING' && Number(s.toMemberId) === _myChipId;
      });
      var cnt = incoming.length;
      if (!cnt) { el.innerHTML = ''; return; }
      el.innerHTML = '<div class="exp-home-settle-chip" onclick="switchExpTab(\'settle\', document.querySelectorAll(\'.exp-itab\')[2])">'
        + '<div>'
        +   '<div style="font-size:13px;font-weight:700;color:#2D3748;">📬 정산 요청 왔어요</div>'
        +   '<div style="font-size:11px;color:var(--light);margin-top:2px;">정산 탭에서 확인하세요</div>'
        + '</div>'
        + '<span style="font-size:11px;font-weight:800;padding:4px 12px;border-radius:50px;'
        + 'background:rgba(255,182,100,.2);color:#B7791F;border:1px solid rgba(255,182,100,.35);">'
        + cnt + '건</span>'
        + '</div>';
    })
    .catch(function() { el.innerHTML = ''; });
}

/* ═══════════════════════════════════════════
   ② 내역 탭 — 지출 목록
   GET /api/trips/{tripId}/expenses?page=1&size=50
   response: List<SummaryResponse>
     { expenseId, tripId, payerId, payerNickname,
       category, amount, description, expenseDate,
       paymentType, createdAt }
═══════════════════════════════════════════ */
function loadExpenseList() {
  var listEl = document.getElementById('expenseList');
  if (!listEl) return;
  listEl.innerHTML = '<div class="expense-empty-state"><div class="expense-empty-state__icon">⏳</div>'
    + '<div class="expense-empty-state__title">불러오는 중...</div></div>';

  fetch(CTX_PATH + '/api/trips/' + TRIP_ID + '/expenses?page=1&size=50')
    .then(function(r) { return r.ok ? r.json() : Promise.reject(r.status); })
    .then(function(list) {
      list = (list || []).map(normalizeRow);

      /* 건수 배지 */
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

      var myMid = typeof MY_MEMBER_ID !== 'undefined' ? Number(MY_MEMBER_ID) : -1;

      /* 날짜순 정렬 (최신순) */
      list.sort(function(a, b) {
        var da = String(a.expenseDate || '');
        var db = String(b.expenseDate || '');
        return db.localeCompare(da);
      });

      /* 날짜별 그룹핑 */
      var grouped = {};
      var dateOrder = [];
      list.forEach(function(e) {
        var d = e.expenseDate ? String(e.expenseDate).substring(0, 10) : '날짜 없음';
        if (!grouped[d]) { grouped[d] = []; dateOrder.push(d); }
        grouped[d].push(e);
      });

      var groupedHtml = '';
      dateOrder.forEach(function(d) {
        var label = d !== '날짜 없음' ? d.substring(5).replace(/-/g, '/') : '날짜 없음';
        groupedHtml += '<div class="exp-list-date-group">'
          + '<div class="exp-list-date-label">' + label + '</div>';
        grouped[d].forEach(function(e) {
          /* 아래 map 로직 인라인 */
          var k       = (e.category || 'ETC').toUpperCase();
          var icon    = _CAT_ICON[k] || '📦';
          var catName = _CAT_NAME[k] || '기타';
          var date    = e.expenseDate ? String(e.expenseDate).substring(5).replace(/-/g, '/') : '';
          var hasMemo    = !!(e.memo && String(e.memo).trim());
          var hasReceipt = !!(e.receiptUrl && String(e.receiptUrl).trim());
          var catBg = _CAT_COLOR[k] || _CAT_COLOR.ETC;
          groupedHtml += '<div class="expense-item" onclick="openExpenseDetail(' + e.expenseId + ')">'
            + '<div class="expense-item__cat-icon" style="background:' + catBg + '">' + icon + '</div>'
            + '<div class="expense-item__info">'
            +   '<div class="expense-item__name">' + _esc(e.description || '') + '</div>'
            +   '<div class="expense-item__meta">'
            +     '<span class="expense-item__cat">' + catName + '</span>'
            +     '<span class="expense-item__meta-dot">·</span>'
            +     '<span class="expense-item__payer">' + _esc(e.payerNickname || '?') + '</span>'
            +     (hasMemo    ? '<span class="expense-extra-badge">📝</span>' : '')
            +     (hasReceipt ? '<span class="expense-extra-badge expense-extra-badge--img">📷</span>' : '')
            +   '</div>'
            + '</div>'
            + '<div class="expense-item__right">'
            +   '<div class="expense-item__amt">₩ ' + Number(e.amount || 0).toLocaleString() + '</div>'
            +   '<button class="expense-del-btn" onclick="event.stopPropagation();deleteExpenseItem(' + e.expenseId + ')" title="삭제">✕</button>'
            + '</div>'
            + '</div>';
        });
        groupedHtml += '</div>';
      });
      listEl.innerHTML = groupedHtml;
      return; /* grouped 렌더 후 종료 */

      listEl.innerHTML = list.map(function(e) {
        var k       = (e.category || 'ETC').toUpperCase();
        var icon    = _CAT_ICON[k] || '📦';
        var catName = _CAT_NAME[k] || '기타';
        var date    = e.expenseDate ? String(e.expenseDate).substring(5).replace(/-/g, '/') : '';
        /* 결제 수단 표시 */
        var pmtLabel = e.paymentType ? e.paymentType : '';

        /* 메모/영수증 표시 여부 */
        var hasMemo    = !!(e.memo && String(e.memo).trim());
        var hasReceipt = !!(e.receiptUrl && String(e.receiptUrl).trim());
        var hasExtra   = hasMemo || hasReceipt;

        /* 카테고리 배경 */
        var catBg = _CAT_COLOR[k] || _CAT_COLOR.ETC;
        return '<div class="expense-item" onclick="openExpenseDetail(' + e.expenseId + ')">'
          + '<div class="expense-item__cat-icon" style="background:' + catBg + '">' + icon + '</div>'
          + '<div class="expense-item__info">'
          +   '<div class="expense-item__name">' + _esc(e.description || '') + '</div>'
          +   '<div class="expense-item__meta">'
          +     '<span class="expense-item__date">' + date + '</span>'
          +     '<span class="expense-item__meta-dot">·</span>'
          +     '<span class="expense-item__cat">' + catName + '</span>'
          +     '<span class="expense-item__meta-dot">·</span>'
          +     '<span class="expense-item__payer">' + _esc(e.payerNickname || '?') + '</span>'
          +     (hasMemo    ? '<span class="expense-extra-badge">📝</span>' : '')
          +     (hasReceipt ? '<span class="expense-extra-badge expense-extra-badge--img">📷</span>' : '')
          +   '</div>'
          + '</div>'
          + '<div class="expense-item__right">'
          +   '<div class="expense-item__amt">₩ ' + Number(e.amount || 0).toLocaleString() + '</div>'
          +   '<button class="expense-del-btn" onclick="event.stopPropagation();deleteExpenseItem(' + e.expenseId + ')" title="삭제">✕</button>'
          + '</div>'
          + '</div>';
      }).join('');
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

/* ═══════════════════════════════════════════
   ③ 정산 탭 — 미리보기 로드
   GET /api/trips/{tripId}/settlements/preview
   response: { tripId, details: [{
     fromMemberId, fromMemberNickname,
     toMemberId, toMemberNickname, amount }] }
═══════════════════════════════════════════ */

/* 내가 받은 정산 요청 로드 (toMemberId = 나 + PENDING) */
function _loadReceivedSettlements() {
  var rcvSec  = document.getElementById('settleReceivedSection');
  var rcvList = document.getElementById('settleReceivedList');
  if (!rcvSec || !rcvList) return;

  var myMid = (typeof MY_MEMBER_ID !== 'undefined') ? Number(MY_MEMBER_ID) : 0;
  if (!myMid) return;

  var url = CTX_PATH + '/api/trips/' + TRIP_ID + '/settlements?memberId=' + myMid;
  fetch(url)
    .then(function(r) { return r.ok ? r.json() : null; })
    .then(function(data) {
      var list = data && data.settlements ? data.settlements : [];
      /* 나한테 온 PENDING 정산만 */
      var incoming = list.filter(function(s) {
        return Number(s.toMemberId) === myMid && s.status === 'PENDING';
      });

      if (!incoming.length) { rcvSec.style.display = 'none'; return; }

      rcvSec.style.display = '';
      rcvList.innerHTML = incoming.map(function(s) {
        var from = _esc(s.fromMemberNickname || s.fromNickname || '?');
        var amt  = Number(s.amount || 0).toLocaleString();
        return '<div class="settle-card settle-card--recv" style="margin-bottom:8px;">'
          + '<div class="settle-card__kp">'
          +   '<div class="settle-card__kp-amt settle-card__kp-amt--recv">₩ ' + amt + '</div>'
          +   '<div class="settle-card__kp-desc">'
          +     '<div class="settle-card__avatar settle-card__avatar--from">' + String(from).substring(0,2) + '</div>'
          +     '<div class="settle-card__kp-names">'
          +       '<span class="settle-card__kp-from">' + from + '</span>'
          +       '<span class="settle-card__kp-arrow">이(가)</span>'
          +       '<span class="settle-card__kp-to">나</span>'
          +       '<span class="settle-card__kp-action-label">에게 요청</span>'
          +     '</div>'
          +   '</div>'
          + '</div>'
          + '<div class="settle-card__footer">'
          +   '<span class="settle-status-badge settle-status-badge--recv" style="font-size:11px;">📬 정산 요청 받음</span>'
          +   '<div class="settle-card__actions">'
          +     '<span style="font-size:11px;color:#718096;">계좌 이체 후 완료 처리 하세요</span>'
          +   '</div>'
          + '</div>'
          + '</div>';
      }).join('');
    })
    .catch(function() { if (rcvSec) rcvSec.style.display = 'none'; });
}

function _loadSettleTab() {
  var settleSection    = document.getElementById('settleSection');
  var settleDoneSection = document.getElementById('settleDoneSection');
  var settleEmpty      = document.getElementById('settleEmpty');
  var settleList       = document.getElementById('settleList');
  var rcvSec           = document.getElementById('settleReceivedSection');
  if (!settleList) return;

  /* 모두 초기화 */
  if (settleSection)    settleSection.style.display    = 'none';
  if (settleDoneSection) settleDoneSection.style.display = 'none';
  if (settleEmpty)      settleEmpty.style.display      = 'none';
  if (rcvSec)           rcvSec.style.display           = 'none';
  settleList.innerHTML = '<div style="text-align:center;padding:24px;color:var(--light);">불러오는 중...</div>';

  var myMid = (typeof MY_MEMBER_ID !== 'undefined' && MY_MEMBER_ID) ? Number(MY_MEMBER_ID) : 0;

  /* preview API: 정산 계산 결과 */
  fetch(CTX_PATH + '/api/trips/' + TRIP_ID + '/settlements/preview')
    .then(function(r) { return r.ok ? r.json() : Promise.reject(r.status); })
    .then(function(data) {
      var list = data && data.details ? data.details : [];

      if (!list.length) {
        if (settleSection) settleSection.style.display = 'none';
        if (settleEmpty)   settleEmpty.style.display   = '';
        settleList.innerHTML = '';
        return;
      }

      if (settleSection) settleSection.style.display = '';
      if (settleEmpty)   settleEmpty.style.display   = 'none';

      /* 나와 관련된 정산만 표시 */
      var mySettles = list.filter(function(s) {
        return Number(s.fromMemberId) === myMid || Number(s.toMemberId) === myMid;
      });

      /* ─────────────────────────────────────────
         내가 받을 정산 = toMemberId=나 (내가 결제, 상대가 줘야 함)
         내가 줘야 할 정산 = fromMemberId=나 (상대가 결제, 내가 줘야 함)
         ───────────────────────────────────────── */
      var toRecv = mySettles.filter(function(s) { return Number(s.toMemberId)   === myMid; });
      var toSend = mySettles.filter(function(s) { return Number(s.fromMemberId) === myMid; });

      var html = '';

      /* ① 내가 받을 정산 (내가 결제 → 상대에게 요청 가능) */
      if (toRecv.length) {
        html += '<div class="settle-section-title">💳 내가 받을 정산</div>';
        html += '<div class="settle-section-desc">내가 결제한 금액 중 상대방 몫이에요. 요청을 보내세요.</div>';
        html += toRecv.map(function(s) {
          var from = _esc(s.fromMemberNickname || s.fromNickname || '?');
          var amt  = Number(s.amount || 0).toLocaleString();
          return '<div class="settle-card settle-card--recv">'
            + '<div class="settle-card__kp">'
            +   '<div class="settle-card__kp-amt settle-card__kp-amt--recv">₩ ' + amt + '</div>'
            +   '<div class="settle-card__kp-desc">'
            +     '<div class="settle-card__avatar settle-card__avatar--from">' + String(from).substring(0,2) + '</div>'
            +     '<div class="settle-card__kp-names">'
            +       '<span class="settle-card__kp-from">' + from + '</span>'
            +       '<span class="settle-card__kp-arrow">→</span>'
            +       '<span class="settle-card__kp-to">나</span>'
            +       '<span class="settle-card__kp-action-label">에게</span>'
            +     '</div>'
            +   '</div>'
            + '</div>'
            + '<div class="settle-card__footer">'
            +   '<span class="settle-status-badge settle-status-badge--recv">💚 받을 예정</span>'
            +   '<div class="settle-card__actions">'
            +     '<button class="settle-card__pay-btn settle-card__pay-btn--request" '
            +       'data-to-nick="' + from + '" data-amount="' + s.amount + '" data-to-mid="' + (s.fromMemberId || 0) + '" '
            +       'onclick="requestSettlementBtn(this)">📬 정산 요청하기</button>'
            +   '</div>'
            + '</div>'
            + '</div>';
        }).join('');
      }

      /* ② 내가 줘야 할 정산 (상대가 결제 → 요청 오면 송금) */
      if (toSend.length) {
        html += '<div class="settle-section-title" style="margin-top:' + (toRecv.length ? '16px' : '0') + '">💸 내가 줘야 할 정산</div>';
        html += '<div class="settle-section-desc">상대방 결제 중 내 몫이에요. 요청이 오면 송금해주세요.</div>';
        html += toSend.map(function(s) {
          var to  = _esc(s.toMemberNickname || s.toNickname || '?');
          var amt = Number(s.amount || 0).toLocaleString();
          return '<div class="settle-card">'
            + '<div class="settle-card__kp">'
            +   '<div class="settle-card__kp-amt">₩ ' + amt + '</div>'
            +   '<div class="settle-card__kp-desc">'
            +     '<div class="settle-card__avatar settle-card__avatar--from">나</div>'
            +     '<div class="settle-card__kp-names">'
            +       '<span class="settle-card__kp-from">나</span>'
            +       '<span class="settle-card__kp-arrow">→</span>'
            +       '<span class="settle-card__kp-to">' + to + '</span>'
            +       '<span class="settle-card__kp-action-label">님께</span>'
            +     '</div>'
            +   '</div>'
            + '</div>'
            + '<div class="settle-card__footer">'
            +   '<span class="settle-status-badge settle-status-badge--pending">⏳ 대기 중</span>'
            +   '<div class="settle-card__actions" style="font-size:11px;color:#A0AEC0;">요청을 기다리세요</div>'
            + '</div>'
            + '</div>';
        }).join('');
      }

      if (!mySettles.length) {
        html = '<div style="text-align:center;padding:24px;color:var(--light);font-size:13px;">관련 정산이 없어요</div>';
      }

      if (mySettles.length) {
        html += '<button class="btn-settle-confirm" onclick="confirmSettlement()">정산 내역 저장하기</button>';
        html += '<div style="text-align:center;font-size:11px;color:#A0AEC0;margin-top:6px;">저장 후 완료 처리 가능</div>';
      }
            settleList.innerHTML = html;

      /* 정산이 DB에 저장된 경우 받은 요청도 표시 */
      _loadReceivedSettlements();
    })
    .catch(function(err) {
      console.warn('[Settlement] 미리보기 실패:', err);
      if (settleSection) settleSection.style.display = 'none';
      if (settleEmpty)   settleEmpty.style.display   = '';
      settleList.innerHTML = '';
    });
}

/* 개별 정산 요청 — 특정 멤버에게만 요청 */
function requestSettlementBtn(btn) {
  var toNick    = btn.getAttribute('data-to-nick') || '?';
  var amount    = parseFloat(btn.getAttribute('data-amount')) || 0;
  var toMemberId = parseInt(btn.getAttribute('data-to-mid')) || 0;
  requestSettlementToOther(toNick, amount, toMemberId);
}

function requestSettlementToOther(toNick, amount, toMemberId) {
  var myMid = (typeof MY_MEMBER_ID !== 'undefined') ? Number(MY_MEMBER_ID) : 0;
  var myNick = (typeof MEMBER_DICT !== 'undefined' && MEMBER_DICT[myMid]) ? MEMBER_DICT[myMid] : '나';

  /* 알림 발송 */
  if (toMemberId) {
    fetch(CTX_PATH + '/api/notification/send', {
      method:  'POST',
      headers: { 'Content-Type': 'application/json' },
      body:    JSON.stringify({
        tripId:     TRIP_ID,
        receiverId: toMemberId,
        message:    myNick + '님이 정산을 요청했어요 ₩' + Number(amount).toLocaleString(),
        type:       'SETTLEMENT'
      })
    }).catch(function() {});
  }

  showToast('📬 ' + _esc(toNick) + '님에게 정산 요청을 보냈어요!');
}


/* 정산 미리보기 row HTML — settle-card 형태 */
function _renderSettlePreviewRows(list) {
  return list.map(function(s) {
    var from = _esc(s.fromMemberNickname || s.fromNickname || '?');
    var to   = _esc(s.toMemberNickname   || s.toNickname   || '?');
    var amt  = Number(s.amount || 0).toLocaleString();
    var fromAv = String(from).substring(0, 2);
    var toAv   = String(to).substring(0, 2);
    return '<div class="settle-card">'
      + '<div class="settle-card__kp">'
      +   '<div class="settle-card__kp-amt">₩ ' + amt + '</div>'
      +   '<div class="settle-card__kp-desc">'
      +     '<div class="settle-card__avatar settle-card__avatar--from">' + fromAv + '</div>'
      +     '<div class="settle-card__kp-names">'
      +       '<span class="settle-card__kp-from">' + from + '</span>'
      +       '<span class="settle-card__kp-arrow">→</span>'
      +       '<span class="settle-card__kp-to">' + to + '</span>'
      +       '<span class="settle-card__kp-action-label">님께</span>'
      +     '</div>'
      +   '</div>'
      + '</div>'
      + '<div class="settle-card__footer">'
      +   '<span class="settle-status-badge settle-status-badge--pending">⏳ 정산 대기</span>'
      +   '<div class="settle-card__actions">'
      +     '<button class="settle-card__detail-btn" onclick="openSettleDetail(null,\'' + from + '\',\'' + to + '\',' + s.amount + ')">상세</button>'
      +   '</div>'
      + '</div>'
      + '</div>';
  }).join('');
}

/* ═══════════════════════════════════════════
   정산 확정 (POST → DB 저장)
   POST /api/trips/{tripId}/settlements
   body: { tripId, batchId: null }
═══════════════════════════════════════════ */
function confirmSettlement() {
  /* confirm 제거 — 토스트로만 피드백 */
  var btn = document.querySelector('.btn-settle-confirm');
  if (btn) { btn.disabled = true; btn.textContent = '요청 중...'; }

  var _cMid = (typeof LOGIN_MEMBER_ID !== 'undefined' && LOGIN_MEMBER_ID && Number(LOGIN_MEMBER_ID) > 0)
    ? Number(LOGIN_MEMBER_ID)
    : (typeof MY_MEMBER_ID !== 'undefined' && MY_MEMBER_ID && Number(MY_MEMBER_ID) > 0 ? Number(MY_MEMBER_ID) : null);
  var _cUrl = CTX_PATH + '/api/trips/' + TRIP_ID + '/settlements' + (_cMid ? '?memberId=' + _cMid : '');
  fetch(_cUrl, {
    method:  'POST',
    headers: { 'Content-Type': 'application/json' },
    body:    JSON.stringify({ tripId: TRIP_ID, batchId: null })
  })
  .then(function(r) { return r.ok ? r.json() : Promise.reject(r.status); })
  .then(function(data) {
    showToast('💸 정산 요청이 완료됐어요! 멤버들에게 알림을 보냈어요.');
    /* 정산 완료 내역 탭으로 전환 */
    loadSavedSettlements();
    _renderSettleStatusChip();
    /* 알림 발송 — 각 정산 대상자에게 */
    _sendSettlementNotification(data);
  })
  .catch(function(e) {
    console.error('[Settlement] 정산 요청 실패', e);
    showToast('⚠️ 정산 요청에 실패했어요');
    if (btn) { btn.disabled = false; btn.textContent = '정산 요청하기'; }
  });
}

/* 정산 요청 후 각 대상자에게 알림 발송 */
function _sendSettlementNotification(data) {
  /* settlements 배열에서 fromMemberId를 추출해 각자에게 알림 */
  var settlements = (data && data.settlements) ? data.settlements : [];
  settlements.forEach(function(s) {
    var receiverId = s.fromMemberId;
    var toNick     = s.toMemberNickname || s.toNickname || '';
    var amt        = Number(s.amount || 0).toLocaleString();
    if (!receiverId) return;
    fetch(CTX_PATH + '/api/notification/send', {
      method:  'POST',
      headers: { 'Content-Type': 'application/json' },
      body:    JSON.stringify({
        tripId:     TRIP_ID,
        receiverId: receiverId,
        message:    toNick + '님께 ₩' + amt + ' 정산 요청이 왔어요',
        type:       'SETTLEMENT'
      })
    }).catch(function() {}); /* 알림 실패는 조용히 무시 */
  });
}

/* ═══════════════════════════════════════════
   확정된 정산 조회
   GET /api/trips/{tripId}/settlements
   response: { settlements: [{
     settlementId, fromMemberNickname, toMemberNickname,
     amount, status, settledAt, createdAt }] }
═══════════════════════════════════════════ */
function loadSavedSettlements() {
  /* settleSection 숨기고 완료 내역 섹션 표시 */
  var settleSection    = document.getElementById('settleSection');
  var settleDoneSection = document.getElementById('settleDoneSection');
  var settleDoneList   = document.getElementById('settleDoneList');
  var settleDoneEmpty  = document.getElementById('settleDoneEmpty');
  var settleEmpty      = document.getElementById('settleEmpty');

  if (settleSection)    settleSection.style.display    = 'none';
  if (settleEmpty)      settleEmpty.style.display      = 'none';
  if (settleDoneSection) settleDoneSection.style.display = '';
  if (settleDoneList)   settleDoneList.innerHTML = '<div style="text-align:center;padding:24px;color:var(--light);font-size:13px;">불러오는 중...</div>';
  if (settleDoneEmpty)  settleDoneEmpty.style.display  = 'none';
  /* settleReceivedSection 숨김 (완료 내역에 통합) */
  var _rcvSec = document.getElementById('settleReceivedSection');
  if (_rcvSec) _rcvSec.style.display = 'none';

  var _mid = (typeof LOGIN_MEMBER_ID !== 'undefined' && LOGIN_MEMBER_ID && Number(LOGIN_MEMBER_ID) > 0)
    ? Number(LOGIN_MEMBER_ID)
    : (typeof MY_MEMBER_ID !== 'undefined' && MY_MEMBER_ID && Number(MY_MEMBER_ID) > 0 ? Number(MY_MEMBER_ID) : null);
  var _sUrl = CTX_PATH + '/api/trips/' + TRIP_ID + '/settlements' + (_mid ? '?memberId=' + _mid : '');
  fetch(_sUrl)
    .then(function(r) { return r.ok ? r.json() : Promise.reject(r.status); })
    .then(function(data) {
      var list = data && data.settlements ? data.settlements : [];
      var settleDoneList  = document.getElementById('settleDoneList');
      var settleDoneEmpty = document.getElementById('settleDoneEmpty');

      if (!list.length) {
        if (settleDoneList)  settleDoneList.innerHTML  = '';
        if (settleDoneEmpty) settleDoneEmpty.style.display = '';
        return;
      }

      if (settleDoneEmpty) settleDoneEmpty.style.display = 'none';

      var myMidDone = (typeof MY_MEMBER_ID !== 'undefined') ? Number(MY_MEMBER_ID) : 0;
      /* 내가 보낸/받은 것만 필터 */
      var myList = list.filter(function(s) {
        return Number(s.fromMemberId) === myMidDone || Number(s.toMemberId) === myMidDone;
      });

      if (!myList.length) {
        if (settleDoneList)  settleDoneList.innerHTML  = '';
        if (settleDoneEmpty) settleDoneEmpty.style.display = '';
        return;
      }

      /* 내가 보낸 것(fromMemberId=나) 과 받은 것(toMemberId=나) 분리 */
      var sentList = myList.filter(function(s) { return Number(s.fromMemberId) === myMidDone; });
      var recvList = myList.filter(function(s) { return Number(s.toMemberId)   === myMidDone; });

      function _makeCard(s, isSentByMe) {
        var amMyReceiver = !isSentByMe; /* toMemberId = 나 → 내가 완료처리 */
        var from   = _esc(s.fromMemberNickname || s.fromNickname || '?');
        var to     = _esc(s.toMemberNickname   || s.toNickname   || '?');
        var amt    = Number(s.amount || 0).toLocaleString();
        var isDone = s.status === 'COMPLETED';
        var fromAv = String(from).substring(0, 2);
        return '<div class="settle-card' + (isDone ? ' settle-card--done' : (isSentByMe ? '' : ' settle-card--recv')) + '">'
          + '<div class="settle-card__kp">'
          +   '<div class="settle-card__kp-amt' + (isDone ? ' settle-card__kp-amt--done' : (isSentByMe ? '' : ' settle-card__kp-amt--recv')) + '">₩ ' + amt + '</div>'
          +   '<div class="settle-card__kp-desc">'
          +     '<div class="settle-card__avatar settle-card__avatar--from">' + fromAv + '</div>'
          +     '<div class="settle-card__kp-names">'
          +       '<span class="settle-card__kp-from">' + (isSentByMe ? '나' : from) + '</span>'
          +       '<span class="settle-card__kp-arrow">→</span>'
          +       '<span class="settle-card__kp-to">' + (isSentByMe ? to : '나') + '</span>'
          +       '<span class="settle-card__kp-action-label">' + (isSentByMe ? '님께' : '에게') + '</span>'
          +     '</div>'
          +   '</div>'
          + '</div>'
          + '<div class="settle-card__footer">'
          +   (isDone
              ? '<span class="settle-status-badge settle-status-badge--done">✅ 송금 완료</span>'
              : (isSentByMe
                  ? '<span class="settle-status-badge settle-status-badge--pending">⏳ 대기 중</span>'
                  : '<span class="settle-status-badge settle-status-badge--recv">💚 받을 예정</span>'))
          +   '<div class="settle-card__actions">'
          +     '<button class="settle-card__detail-btn" '
          +       'data-sid="' + (s.settlementId || '') + '" '
          +       'data-from="' + from + '" data-to="' + to + '" data-amt="' + s.amount + '" '
          +       'onclick="openSettleDetailBtn(this)">상세</button>'
          +     (!isDone && !isSentByMe
                ? '<button class="settle-card__pay-btn" onclick="completeSettlement(this,' + s.settlementId + ')">✅ 완료 처리</button>'
                : '')
          +     '<button class="settle-card__del-btn" onclick="deleteSettlement(this,' + s.settlementId + ')" title="삭제">🗑</button>'
          +   '</div>'
          + '</div>'
          + '</div>';
      }

      var html = '';
      if (sentList.length) {
        html += '<div class="settle-section-title">💸 내가 보낸 정산</div>';
        html += sentList.map(function(s) { return _makeCard(s, true);  }).join('');
      }
      if (recvList.length) {
        html += '<div class="settle-section-title" style="margin-top:' + (sentList.length ? '14px' : '0') + '">💚 내가 받을 정산</div>';
        html += recvList.map(function(s) { return _makeCard(s, false); }).join('');
      }
      settleDoneList.innerHTML = html;
    })
    .catch(function(err) {
      console.warn('[Settlement] 완료 내역 조회 실패:', err);
      var settleDoneList  = document.getElementById('settleDoneList');
      var settleDoneEmpty = document.getElementById('settleDoneEmpty');
      if (settleDoneList)  settleDoneList.innerHTML = '';
      if (settleDoneEmpty) settleDoneEmpty.style.display = '';
    });
}

/* ═══════════════════════════════════════════
   송금 완료 처리
   PATCH /api/settlements/complete
   body: { settlementIds: [settlementId] }
═══════════════════════════════════════════ */

function deleteSettlement(btn, settlementId) {
  if (!settlementId) { showToast('⚠️ 정산 ID가 없어요'); return; }
  if (!confirm('이 정산 내역을 삭제할까요?')) return;
  btn.disabled = true;
  fetch(CTX_PATH + '/api/settlements/' + settlementId, { method: 'DELETE' })
    .then(function(r) {
      if (r.ok || r.status === 204) {
        var card = btn.closest('.settle-card');
        if (card) {
          card.style.transition = 'opacity .25s, transform .25s';
          card.style.opacity    = '0';
          card.style.transform  = 'translateX(20px)';
          setTimeout(function() { card.remove(); }, 250);
        }
        showToast('🗑 삭제됐어요');
      } else {
        btn.disabled = false;
        showToast('⚠️ 삭제에 실패했어요');
      }
    })
    .catch(function() { btn.disabled = false; showToast('⚠️ 서버 오류'); });
}

function completeSettlement(btn, settlementId) {
  if (!settlementId) { showToast('⚠️ 정산 ID가 없어요'); return; }
  btn.disabled    = true;
  btn.textContent = '처리 중...';

  fetch(CTX_PATH + '/api/settlements/complete', {
    method:  'PATCH',
    headers: { 'Content-Type': 'application/json' },
    body:    JSON.stringify({ settlementIds: [settlementId] })
  })
  .then(function(r) {
    if (r.ok) {
      showToast('✅ 송금 완료로 처리됐어요!');
      /* 현황에서 제거하고 완료 내역 섹션으로 이동 */
      var card = btn.closest('.settle-card');
      if (card) {
        /* 카드를 완료 스타일로 바꾼 뒤 settleDoneList로 이동 */
        card.classList.add('settle-card--done');
        var kpAmt = card.querySelector('.settle-card__kp-amt');
        if (kpAmt) kpAmt.classList.add('settle-card__kp-amt--done');
        /* footer 교체 */
        var footer = card.querySelector('.settle-card__footer');
        if (footer) {
          footer.innerHTML = '<span class="settle-status-badge settle-status-badge--done">✅ 송금 완료</span>'
            + '<span class="settle-done-label">✅ 완료됨</span>';
        }
        card.remove();

        /* settleDoneSection으로 이동 */
        var doneList = document.getElementById('settleDoneList');
        var doneEmpty = document.getElementById('settleDoneEmpty');
        var doneSec = document.getElementById('settleDoneSection');
        if (doneList) {
          doneList.insertBefore(card, doneList.firstChild);
          if (doneEmpty) doneEmpty.style.display = 'none';
        }
        if (doneSec) doneSec.style.display = '';

        /* 정산 현황(settleList)이 비었으면 빈 상태 표시 */
        var settleList = document.getElementById('settleList');
        if (settleList && !settleList.querySelector('.settle-card')) {
          settleList.innerHTML = '<div style="text-align:center;padding:24px;color:var(--light);font-size:13px;">'
            + '모든 정산이 완료됐어요 🎉</div>';
        }
      }
      _renderSettleStatusChip();
    } else {
      btn.disabled = false; btn.textContent = '송금 완료';
      showToast('⚠️ 처리에 실패했어요');
    }
  })
  .catch(function() {
    btn.disabled = false; btn.textContent = '송금 완료';
    showToast('⚠️ 서버 오류');
  });
}

/* ═══════════════════════════════════════════
   지출 추가 (POST)
   POST /api/trips/{tripId}/expenses
   body: { description, amount, category, payerId,
           expenseDate, paymentType, memo, participants }
═══════════════════════════════════════════ */
function submitExpense() {
  var description = document.getElementById('exp-name').value.trim();
  var amount      = parseFloat(document.getElementById('exp-amt').value) || 0;
  var category    = document.getElementById('exp-cat').value;

  /* 결제자: 드롭다운 hidden input에서 읽기 */
  var payerEl = document.getElementById('exp-payer-value');
  var payerId = payerEl ? parseInt(payerEl.value) : null;

  var expenseDate = document.getElementById('exp-date').value;
  var pmtTypeEl   = document.getElementById('exp-payment-type');
  var paymentType = pmtTypeEl ? pmtTypeEl.value : '';
  var memoEl      = document.getElementById('exp-memo');
  var memo        = memoEl ? memoEl.value.trim() : '';

  if (!description)              { showToast('⚠️ 항목명을 입력해주세요'); return; }
  if (amount <= 0)               { showToast('⚠️ 금액을 입력해주세요');   return; }
  if (!expenseDate)              { showToast('⚠️ 날짜를 선택해주세요');   return; }
  if (!payerId || isNaN(payerId)){ showToast('⚠️ 결제자를 선택해주세요'); return; }

  var allParts = _getAllParticipants();
  if (!allParts.length) { showToast('⚠️ 분담자를 1명 이상 선택해주세요'); return; }

  /* 전체 인원(WS + ext) 동일 단가 × (인원수) = amount 보장
     → 서버 validateParticipantsTotal 통과 */
  var wsParts = allParts.filter(function(p) { return String(p.id).indexOf('ext_') !== 0; });
  if (!wsParts.length) { showToast('⚠️ 워크스페이스 참여자가 최소 1명 필요해요'); return; }

  var totalCnt  = allParts.length;
  var basePerHead = Math.floor(amount / totalCnt);
  var remainder   = amount - basePerHead * totalCnt;  /* 1원 나머지 → 첫 번째 참여자에게 */

  var participants = [];
  allParts.forEach(function(p, idx) {
    var isExt = String(p.id).indexOf('ext_') === 0;
    participants.push({
      memberId:    isExt ? null : parseInt(p.id),
      nickname:    isExt ? p.nick : null,
      shareAmount: basePerHead + (idx === 0 ? remainder : 0)
    });
  });
  /* ✓ 합계 = basePerHead × totalCnt + remainder = amount — 서버 검증 통과 */

  var btn = document.querySelector('.exp-submit-btn') || document.getElementById('expSubmitBtn');
  if (btn) { btn.disabled = true; btn.textContent = '추가 중...'; }

  /* 영수증 이미지 업로드 후 지출 등록 */
  var receiptFile = document.getElementById('exp-receipt');
  var uploadPromise;

  if (receiptFile && receiptFile.files && receiptFile.files[0]) {
    var fd = new FormData();
    fd.append('file', receiptFile.files[0]);
    uploadPromise = fetch(CTX_PATH + '/api/upload/image', {
      method: 'POST',
      body: fd
    })
    .then(function(r) { return r.ok ? r.json() : null; })
    .then(function(data) { return data && data.url ? data.url : null; })
    .catch(function() { return null; }); /* 업로드 실패 시 null로 계속 진행 */
  } else {
    uploadPromise = Promise.resolve(null);
  }

  uploadPromise.then(function(receiptUrl) {
  fetch(CTX_PATH + '/api/trips/' + TRIP_ID + '/expenses', {
    method:  'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      description:  description,
      amount:       amount,
      category:     category,
      payerId:      payerId,
      expenseDate:  expenseDate,
      paymentType:  paymentType || null,
      memo:         memo || null,
      receiptUrl:   receiptUrl || null,
      participants: participants
    })
  })
  .then(function(r) {
    if (!r.ok) return r.json().then(function(e) { throw e; });
    return r.json();
  })
  .then(function() {
    closeModal('addExpenseModal');
    _resetExpenseForm();
    _wsParticipants   = [];
    _extraParticipants = [];
    _extraIdCounter   = 0;
    showToast('✅ 지출이 추가됐어요!');
    /* 현재 활성 탭 갱신 — 내역 탭으로 이동 */
    var listBtn = document.querySelectorAll('.exp-itab')[1];
    switchExpTab('list', listBtn);
  })
  .catch(function(e) {
    console.error('[Expense] 추가 실패', e);
    alert((e && e.message) || '지출 추가에 실패했어요. 잠시 후 다시 시도해주세요.');
  })
  .finally(function() {
    var _btn = document.querySelector('.exp-submit-btn') || document.getElementById('expSubmitBtn');
    if (_btn) { _btn.disabled = false; _btn.textContent = '지출 추가하기'; }
  });
  }); /* uploadPromise end */
}

/* ═══════════════════════════════════════════
   결제자 드롭다운
═══════════════════════════════════════════ */
function togglePayerMenu() {
  var btn  = document.getElementById('expPayerBtn');
  var menu = document.getElementById('expPayerMenu');
  if (!btn || !menu) return;
  var isOpen = menu.classList.contains('open');
  menu.classList.toggle('open', !isOpen);
  btn.classList.toggle('open', !isOpen);
  if (!isOpen) {
    /* 메뉴 외부 클릭 시 닫기 */
    setTimeout(function() {
      document.addEventListener('click', _closePayerMenuOutside, { once: true });
    }, 0);
  }
}
function _closePayerMenuOutside(e) {
  var dropdown = document.getElementById('expPayerDropdown');
  if (dropdown && !dropdown.contains(e.target)) {
    document.getElementById('expPayerMenu').classList.remove('open');
    document.getElementById('expPayerBtn').classList.remove('open');
  }
}
function selectPayer(memberId, nickname, isMe) {
  /* hidden input 업데이트 */
  var hidden = document.getElementById('exp-payer-value');
  if (hidden) hidden.value = memberId;
  /* 버튼 라벨 업데이트 */
  var label = document.getElementById('expPayerBtnLabel');
  if (label) label.textContent = nickname + (isMe ? ' (나)' : '');
  var avatar = document.getElementById('expPayerBtnAvatar');
  if (avatar) avatar.textContent = String(nickname).substring(0, 2);
  /* 선택 강조 */
  document.querySelectorAll('.exp-payer-option').forEach(function(opt) {
    var optId = parseInt(opt.getAttribute('data-id'));
    var chk   = opt.querySelector('.exp-payer-option__check');
    opt.classList.toggle('selected', optId === memberId);
    if (chk) chk.style.display = (optId === memberId) ? '' : 'none';
  });
  /* 드롭다운 닫기 */
  var menu = document.getElementById('expPayerMenu');
  var btn  = document.getElementById('expPayerBtn');
  if (menu) menu.classList.remove('open');
  if (btn)  btn.classList.remove('open');
}

/* ═══════════════════════════════════════════
   정산 상세 모달
═══════════════════════════════════════════ */

function openSettleDetailBtn(btn) {
  var sid  = btn.getAttribute('data-sid') || null;
  var from = btn.getAttribute('data-from') || '?';
  var to   = btn.getAttribute('data-to')   || '?';
  var amt  = parseFloat(btn.getAttribute('data-amt')) || 0;
  openSettleDetail(sid ? parseInt(sid) : null, from, to, amt);
}

function openSettleDetail(settlementId, from, to, amount) {
  var body = document.getElementById('settleDetailBody');
  if (!body) return;

  /* 카카오페이 스타일 요약 헤더 */
  body.innerHTML = '<div class="settle-detail-kp-header">'
    + '<div class="settle-detail-kp-total">총 ' + _esc(from) + ' 외 포함</div>'
    + '<div class="settle-detail-kp-amt">₩ ' + Number(amount || 0).toLocaleString() + '</div>'
    + '<div class="settle-detail-kp-desc">'
    +   '<span class="settle-detail-kp-from">' + _esc(from) + '</span>'
    +   '<span class="settle-detail-kp-arrow"> → </span>'
    +   '<span class="settle-detail-kp-to">' + _esc(to) + '</span>'
    +   '님께'
    + '</div>'
    + '</div>'
    + '<div class="settle-detail-section-title">관련 지출 내역</div>'
    + '<div id="settleDetailExpenses">'
    +   '<div style="text-align:center;padding:24px;color:var(--light);font-size:13px;">불러오는 중...</div>'
    + '</div>'
    + '<div id="settleDetailImages" style="display:none;">'
    + '<div class="settle-detail-section-title" style="margin-top:16px;">영수증 모아보기</div>'
    + '<div id="settleDetailImgGrid" class="settle-detail-img-grid"></div>'
    + '</div>';

  openModal('settleDetailModal');

  fetch(CTX_PATH + '/api/trips/' + TRIP_ID + '/expenses?page=1&size=50')
    .then(function(r) { return r.ok ? r.json() : Promise.reject(r.status); })
    .then(function(list) {
      list = (list || []).map(normalizeRow);
      var detailEl = document.getElementById('settleDetailExpenses');
      var imagesEl = document.getElementById('settleDetailImages');
      var imgGrid  = document.getElementById('settleDetailImgGrid');
      if (!detailEl) return;

      if (!list.length) {
        detailEl.innerHTML = '<div style="text-align:center;padding:20px;color:var(--light);font-size:13px;">관련 지출이 없어요</div>';
        return;
      }

      /* 카테고리별 그룹핑 (카카오페이 스타일) */
      var groups = {};
      var receipts = [];
      list.forEach(function(e) {
        var k = (e.category || 'ETC').toUpperCase();
        if (!groups[k]) groups[k] = { items: [], total: 0 };
        groups[k].items.push(e);
        groups[k].total += Number(e.amount || 0);
        if (e.receiptUrl) receipts.push({ url: e.receiptUrl, name: e.description });
      });

      var html = '';
      _CAT_ORDER.concat(Object.keys(groups).filter(function(k){ return _CAT_ORDER.indexOf(k)===-1; }))
        .filter(function(k){ return groups[k]; })
        .forEach(function(k) {
          var g = groups[k];
          var icon = _CAT_ICON[k] || '📦';
          var catName = _CAT_NAME[k] || k;
          /* 카테고리 헤더 */
          html += '<div class="settle-cat-group">'
            + '<div class="settle-cat-group__head">'
            +   '<span>' + icon + ' ' + catName + '</span>'
            +   '<span class="settle-cat-group__total">₩ ' + g.total.toLocaleString() + '</span>'
            + '</div>';
          /* 각 지출 */
          g.items.forEach(function(e) {
            var perPerson = Math.floor(Number(e.amount || 0) / Math.max(1, 1)); /* 분담자수 없으면 1 */
            html += '<div class="settle-cat-item">'
              + '<div class="settle-cat-item__avatar">' + String(e.payerNickname || '?').substring(0,2) + '</div>'
              + '<div class="settle-cat-item__info">'
              +   '<div class="settle-cat-item__name">' + _esc(e.description || '') + '</div>'
              +   '<div class="settle-cat-item__sub">' + (e.expenseDate ? String(e.expenseDate).substring(5).replace(/-/g,'/') : '') + ' · 결제: ' + _esc(e.payerNickname || '?') + '</div>'
              + '</div>'
              + '<div class="settle-cat-item__amt">₩ ' + Number(e.amount||0).toLocaleString() + '</div>'
              + (e.receiptUrl ? '<button class="settle-cat-item__img-btn" onclick="openImageViewer(\'' + _esc(e.receiptUrl) + '\')" title="영수증 보기">📷</button>' : '')
              + '</div>';
          });
          html += '</div>';
        });

      detailEl.innerHTML = html;

      /* 영수증 그리드 */
      if (receipts.length > 0 && imgGrid && imagesEl) {
        imgGrid.innerHTML = receipts.map(function(r) {
          return '<div class="settle-receipt-thumb" onclick="openImageViewer(\'' + _esc(r.url) + '\')"><img src="' + _esc(r.url) + '" alt="' + _esc(r.name || '') + '" /></div>';
        }).join('');
        imagesEl.style.display = '';
      }
    })
    .catch(function() {
      var detailEl = document.getElementById('settleDetailExpenses');
      if (detailEl) detailEl.innerHTML = '<div style="text-align:center;padding:20px;color:var(--light);font-size:13px;">불러오기 실패</div>';
    });
}

function _resetExpenseForm() {
  ['exp-name', 'exp-amt', 'exp-memo'].forEach(function(id) {
    var el = document.getElementById(id); if (el) el.value = '';
  });
  var pmtEl = document.getElementById('exp-payment-type');
  if (pmtEl) pmtEl.value = '';

  /* 드롭다운 초기화 */
  var menu = document.getElementById('expPayerMenu');
  var btn  = document.getElementById('expPayerBtn');
  if (menu) menu.classList.remove('open');
  if (btn)  btn.classList.remove('open');

  /* 결제자: 드롭다운 첫 번째 옵션(나)으로 초기화 */
  var firstOpt = document.querySelector('.exp-payer-option');
  if (firstOpt) {
    var fid   = firstOpt.getAttribute('data-id');
    var fnick = firstOpt.querySelector('.exp-payer-option__name');
    selectPayer(parseInt(fid), fnick ? fnick.textContent : '나', true);
  }

  /* 분담자: 전원 체크 복원 */
  document.querySelectorAll('#exp-participants input[type=checkbox]').forEach(function(cb) {
    cb.checked = true;
  });
  /* 영수증 초기화 */
  var receiptInput = document.getElementById('exp-receipt');
  if (receiptInput) receiptInput.value = '';
  var receiptPreview = document.getElementById('exp-receipt-preview');
  if (receiptPreview) { receiptPreview.innerHTML = ''; receiptPreview.style.display = 'none'; }
  recalcSharePreview();
}

/* ═══════════════════════════════════════════
   지출 삭제
   DELETE /api/expenses/{expenseId} → 204 No Content
═══════════════════════════════════════════ */
function deleteExpenseItem(expenseId) {
  if (!confirm('이 지출을 삭제할까요?')) return;

  fetch(CTX_PATH + '/api/expenses/' + expenseId, { method: 'DELETE' })
    .then(function(r) {
      if (r.ok) {
        showToast('🗑️ 지출이 삭제됐어요');
        loadExpenseList();
        /* 홈 탭 통계도 갱신 */
        _loadHomeTab();
      } else {
        showToast('⚠️ 삭제에 실패했어요 (' + r.status + ')');
      }
    })
    .catch(function() { showToast('⚠️ 삭제에 실패했어요'); });
}

/* ═══════════════════════════════════════════
   분담 미리보기 재계산 (모달 내)
═══════════════════════════════════════════ */
function recalcSharePreview() {
  var amt     = parseFloat(document.getElementById('exp-amt').value) || 0;
  var checks  = document.querySelectorAll('#exp-participants input[type=checkbox]:checked');
  var cnt     = checks.length;
  var preview = document.getElementById('exp-share-preview');
  if (!preview) return;

  if (cnt > 0 && amt > 0) {
    var per = Math.floor(amt / cnt);
    preview.style.cssText = [
      'display:flex', 'align-items:baseline', 'gap:6px',
      'margin-top:10px', 'padding:12px 14px',
      'background:linear-gradient(120deg,rgba(137,207,240,.1),rgba(194,184,217,.07))',
      'border-radius:10px', 'border:1px solid rgba(137,207,240,.25)'
    ].join(';');
    preview.innerHTML = '<span style="font-size:11px;font-weight:600;color:var(--light);">1인당</span>'
      + '<span style="font-size:22px;font-weight:900;color:#2B6CB0;letter-spacing:-1px;">'
      +   '₩ ' + per.toLocaleString()
      + '</span>';
  } else {
    preview.style.cssText = '';
    preview.innerHTML = '';
  }
}

/* ═══════════════════════════════════════════
   유틸리티
═══════════════════════════════════════════ */

/* ═══════════════════════════════════════════
   영수증 이미지 미리보기
═══════════════════════════════════════════ */
function previewReceiptImage(input) {
  var preview = document.getElementById('exp-receipt-preview');
  var label   = document.getElementById('expReceiptLabel');
  if (!preview || !input.files || !input.files[0]) return;

  var reader = new FileReader();
  reader.onload = function(e) {
    preview.innerHTML = '<div style="position:relative;display:inline-block;">'
      + '<img src="' + e.target.result + '" style="max-width:100%;max-height:160px;'
      + 'border-radius:10px;border:1.5px solid var(--border);object-fit:cover;" />'
      + '<button type="button" onclick="removeReceiptImage()" style="position:absolute;top:-8px;right:-8px;'
      + 'width:22px;height:22px;border-radius:50%;background:#FC8181;border:none;color:white;'
      + 'font-size:11px;font-weight:700;cursor:pointer;display:flex;align-items:center;justify-content:center;">✕</button>'
      + '</div>';
    preview.style.display = 'block';
    if (label) label.querySelector('span').textContent = input.files[0].name;
  };
  reader.readAsDataURL(input.files[0]);
}

function removeReceiptImage() {
  var input   = document.getElementById('exp-receipt');
  var preview = document.getElementById('exp-receipt-preview');
  var label   = document.getElementById('expReceiptLabel');
  if (input)   input.value = '';
  if (preview) { preview.innerHTML = ''; preview.style.display = 'none'; }
  if (label)   label.querySelector('span').textContent = '사진 선택';
}

/* ═══════════════════════════════════════════
   지출 상세 모달
   - 지출명, 금액, 날짜, 카테고리, 결제자
   - 메모 (있을 때)
   - 영수증 이미지 (있을 때, 확대 가능)
═══════════════════════════════════════════ */
function openExpenseDetail(expenseId) {
  var body = document.getElementById('expenseDetailBody');
  if (!body) return;

  /* 로딩 상태 표시 */
  body.innerHTML = '<div style="text-align:center;padding:40px;color:var(--light);">불러오는 중...</div>';
  openModal('expenseDetailModal');

  /* GET /api/expenses/{expenseId} — DetailResponse (memo, receiptUrl 포함) */
  fetch(CTX_PATH + '/api/expenses/' + expenseId)
    .then(function(r) { return r.ok ? r.json() : Promise.reject(r.status); })
    .then(function(e) {
      var k       = (e.category || 'ETC').toUpperCase();
      var icon    = _CAT_ICON[k] || '📦';
      var catName = _CAT_NAME[k] || '기타';
      var date    = e.expenseDate ? String(e.expenseDate).replace(/-/g, '/') : '';
      var hasMemo    = !!(e.memo    && String(e.memo).trim());
      /* receiptUrl 또는 receipt_url 모두 수용 */
      var rawReceipt = e.receiptUrl || e.receipt_url || e.RECEIPT_URL || '';
      var hasReceipt = !!(rawReceipt && String(rawReceipt).trim());
      var participants = e.participants || [];

      var html = '<div class="exp-detail-hero">'
        + '<div class="exp-detail-hero__icon">' + icon + '</div>'
        + '<div class="exp-detail-hero__amt">₩ ' + Number(e.amount || 0).toLocaleString() + '</div>'
        + '<div class="exp-detail-hero__name">' + _esc(e.description || '') + '</div>'
        + '</div>';

      html += '<div class="exp-detail-rows">';
      html += _detailRow('날짜', date);
      html += _detailRow('카테고리', icon + ' ' + catName);
      html += _detailRow('결제자', '👤 ' + _esc(e.payerNickname || '?'));
      if (e.paymentType) html += _detailRow('결제 수단', _esc(e.paymentType));
      html += '</div>';

      /* 분담자 목록 */
      if (participants.length) {
        html += '<div class="exp-detail-section-label">분담 내역</div>'
          + '<div class="exp-detail-rows">';
        participants.forEach(function(p) {
          /* 외부 인원: nickname 컬럼 / WS 멤버: memberNickname */
          var name = _esc(p.memberNickname || p.nickname || p.nick || '?');
          var isExt = !p.memberId;
          html += _detailRow(
            name + (isExt ? ' <span style="font-size:10px;background:#EDF2F7;color:#718096;padding:2px 6px;border-radius:4px;">외부</span>' : ''),
            '₩ ' + Number(p.shareAmount || 0).toLocaleString()
          );
        });
        html += '</div>';
      }

      if (hasMemo) {
        html += '<div class="exp-detail-section-label">메모</div>'
          + '<div class="exp-detail-memo">' + _esc(String(e.memo).trim()) + '</div>';
      }

      if (hasReceipt) {
        var receiptUrl = String(rawReceipt || e.receiptUrl || '').trim();
        html += '<div class="exp-detail-section-label">영수증</div>'
          + '<div class="exp-detail-receipt">'
          + '<img src="' + receiptUrl + '" class="exp-detail-receipt__img" '
          + 'style="max-width:100%;border-radius:10px;cursor:zoom-in;" '
          + 'onclick="openImageViewer(\'' + receiptUrl + '\')" '
          + 'onerror="this.style.display=\'none\';this.nextSibling.style.display=\'block\';" '
          + 'alt="영수증" />'
          + '<div style="display:none;padding:12px;background:var(--bg);border-radius:10px;'
          + 'font-size:12px;color:var(--light);text-align:center;">이미지를 불러올 수 없어요</div>'
          + '<div class="exp-detail-receipt__hint">이미지를 탭하면 확대돼요</div>'
          + '</div>';
      }

      if (!hasMemo && !hasReceipt) {
        html += '<div style="text-align:center;padding:16px 0 4px;color:var(--light);font-size:12px;">첨부된 메모나 영수증이 없어요</div>';
      }

      body.innerHTML = html;
    })
    .catch(function() {
      body.innerHTML = '<div style="text-align:center;padding:30px;color:var(--light);">상세 정보를 불러오지 못했어요</div>';
    });
}

function _detailRow(label, value) {
  return '<div class="exp-detail-row">'
    + '<span class="exp-detail-row__label">' + label + '</span>'
    + '<span class="exp-detail-row__value">' + value + '</span>'
    + '</div>';
}

/* ═══════════════════════════════════════════════════════════
   지출 모달 v2 — 카테고리 칩 선택
═══════════════════════════════════════════════════════════ */
function selectExpCat(val, btn) {
  document.querySelectorAll('.exp-cat-chip').forEach(function(b) { b.classList.remove('active'); });
  btn.classList.add('active');
  var hidden = document.getElementById('exp-cat');
  if (hidden) hidden.value = val;
}

/* ═══════════════════════════════════════════════════════════
   분담자 관리
   - _wsParticipants: 워크스페이스 멤버 [{id, nick, checked}]
   - _extraParticipants: 외부 추가 [{id:'ext_N', nick, checked}]
═══════════════════════════════════════════════════════════ */
var _wsParticipants   = [];   /* 워크스페이스 멤버 */
var _extraParticipants = [];  /* 외부 추가 인원 */
var _extraIdCounter   = 0;

function _getAllParticipants() {
  return _wsParticipants.concat(_extraParticipants).filter(function(p) { return p.checked; });
}

/* 분담자 목록 초기화 (모달 열릴 때) */
function _initParticipants() {
  /* JSP에서 렌더된 체크박스 대신 JS 배열로 관리 */
  if (_wsParticipants.length === 0) {
    /* DOMContentLoaded에서 세팅 불가능하므로 모달 열 때 세팅 */
    document.querySelectorAll('#expPayerMenu .exp-payer-option').forEach(function(opt) {
      var id   = parseInt(opt.getAttribute('data-id'));
      var nick = opt.querySelector('.exp-payer-option__name');
      if (!id || !nick) return;
      _wsParticipants.push({ id: id, nick: nick.textContent.trim(), checked: true });
    });
  }
  _renderSplitList();
}

/* 분담자 목록 렌더 (카카오페이 스타일 — 이름 + 금액) */
function _renderSplitList() {
  var listEl = document.getElementById('exp-split-list');
  var cntEl  = document.getElementById('expSplitCount');
  var noteEl = document.getElementById('exp-remainder-note');
  if (!listEl) return;

  var all   = _getAllParticipants();
  var cnt   = all.length;
  var amt   = parseFloat(document.getElementById('exp-amt') && document.getElementById('exp-amt').value) || 0;

  if (cntEl) cntEl.textContent = '친구 ' + cnt + '명';

  if (!cnt) {
    listEl.innerHTML = '<div style="text-align:center;padding:16px;color:var(--light);font-size:12px;">분담자를 선택해주세요</div>';
    if (noteEl) noteEl.style.display = 'none';
    _updateSubmitBtn();
    return;
  }

  var base      = amt > 0 ? Math.floor(amt / cnt) : 0;
  var remainder = amt > 0 ? (amt - base * cnt) : 0;

  listEl.innerHTML = all.map(function(p, idx) {
    var share = base + (idx === 0 && remainder > 0 ? remainder : 0);
    var isExt = String(p.id).indexOf('ext_') === 0;
    return '<div class="exp-v2-split-item">'
      + '<div class="exp-v2-split-avatar' + (isExt ? ' ext' : '') + '">' + String(p.nick).substring(0,2) + '</div>'
      + '<div class="exp-v2-split-name">' + _esc(p.nick) + (isExt ? ' <span class="ext-badge">외부</span>' : '') + '</div>'
      + '<div class="exp-v2-split-amt">' + (amt > 0 ? '₩ ' + share.toLocaleString() : '—') + '</div>'
      + '</div>';
  }).join('');

  if (noteEl) {
    if (remainder > 0 && amt > 0) {
      noteEl.style.display = '';
      noteEl.textContent = '나머지 ' + remainder + '원은 ' + all[0].nick + '님에게 포함됩니다';
    } else {
      noteEl.style.display = 'none';
    }
  }
  _updateSubmitBtn();
}

/* 확인 버튼 활성/비활성 */
function _updateSubmitBtn() {
  var btn  = document.getElementById('expSubmitBtn');
  var amt  = parseFloat(document.getElementById('exp-amt') && document.getElementById('exp-amt').value) || 0;
  var name = document.getElementById('exp-name') && document.getElementById('exp-name').value.trim();
  var cnt  = _getAllParticipants().length;
  var ok   = amt > 0 && name && cnt > 0;
  if (btn) {
    btn.disabled = !ok;
    btn.style.opacity = ok ? '1' : '0.45';
  }
}

/* ── 분담자 편집 모달 ── */
function openParticipantEditor() {
  var wsEl    = document.getElementById('peWsMembers');
  var extraEl = document.getElementById('peExtraMembers');
  if (!wsEl) return;

  wsEl.innerHTML = '<div style="font-size:11px;font-weight:800;color:var(--light);text-transform:uppercase;letter-spacing:.5px;margin-bottom:8px;">여행 참여자</div>'
    + _wsParticipants.map(function(p) {
        return '<div class="pe-member-row">'
          + '<label style="display:flex;align-items:center;gap:10px;cursor:pointer;">'
          + '<input type="checkbox" ' + (p.checked ? 'checked' : '') + ' data-id="' + p.id + '" onchange="_onPeCheck(this,false)">'
          + '<div class="pe-avatar">' + String(p.nick).substring(0,2) + '</div>'
          + '<span>' + _esc(p.nick) + '</span>'
          + '</label></div>';
      }).join('');

  extraEl.innerHTML = _extraParticipants.length
    ? '<div style="font-size:11px;font-weight:800;color:var(--light);text-transform:uppercase;letter-spacing:.5px;margin-bottom:8px;margin-top:14px;">추가한 인원</div>'
      + _extraParticipants.map(function(p) {
          return '<div class="pe-member-row">'
            + '<label style="display:flex;align-items:center;gap:10px;cursor:pointer;">'
            + '<input type="checkbox" ' + (p.checked ? 'checked' : '') + ' data-id="' + p.id + '" onchange="_onPeCheck(this,true)">'
            + '<div class="pe-avatar ext">' + String(p.nick).substring(0,2) + '</div>'
            + '<span>' + _esc(p.nick) + '</span>'
            + '</label>'
            + '<button onclick="removeExtraPerson(\'' + p.id + '\')" style="background:none;border:none;color:var(--light);cursor:pointer;font-size:16px;">✕</button>'
            + '</div>';
        }).join('')
    : '';

  openModal('participantEditorModal');
}

function _onPeCheck(cb, isExtra) {
  var id  = cb.getAttribute('data-id');
  var arr = isExtra ? _extraParticipants : _wsParticipants;
  var p   = arr.find(function(x) { return String(x.id) === String(id); });
  if (p) p.checked = cb.checked;
}

function addExtraPerson() {
  var input = document.getElementById('peExtraNameInput');
  if (!input) return;
  var nick = input.value.trim();
  if (!nick) { alert('이름을 입력해주세요'); return; }
  if (_extraParticipants.some(function(p){ return p.nick === nick; })) {
    alert('이미 추가된 이름이에요'); return;
  }
  _extraIdCounter++;
  _extraParticipants.push({ id: 'ext_' + _extraIdCounter, nick: nick, checked: true });
  input.value = '';
  openParticipantEditor(); /* 새로고침 */
}

function removeExtraPerson(extId) {
  _extraParticipants = _extraParticipants.filter(function(p) { return p.id !== extId; });
  openParticipantEditor();
}

function applyParticipants() {
  closeModal('participantEditorModal');
  _renderSplitList();
}

/* ── 금액 변경 시 실시간 갱신 ── */
document.addEventListener('DOMContentLoaded', function() {
  /* 기존 DOMContentLoaded에 추가하지 않고 별도 등록 */
  document.addEventListener('input', function(e) {
    if (e.target && (e.target.id === 'exp-amt' || e.target.id === 'exp-name')) {
      _renderSplitList();
      _updateSubmitBtn();
    }
  });
});


/* ═══════════════════════════════════════════
   카테고리 상세 모달
═══════════════════════════════════════════ */
function openCatDetail(category) {
  var body = document.getElementById('catDetailBody');
  var title = document.getElementById('catDetailTitle');
  if (!body || !title) return;

  var icon = _CAT_ICON[category] || '📦';
  var name = _CAT_NAME[category] || category;
  title.textContent = icon + ' ' + name + ' 상세';
  body.innerHTML = '<div style="text-align:center;padding:20px;color:var(--light);">불러오는 중...</div>';
  openModal('catDetailModal');

  fetch(CTX_PATH + '/api/trips/' + TRIP_ID + '/expenses?page=1&size=200')
    .then(function(r) { return r.ok ? r.json() : Promise.reject(r.status); })
    .then(function(list) {
      list = (list || []).map(normalizeRow);
      var filtered = list.filter(function(e) {
        return (e.category || 'ETC').toUpperCase() === category;
      });

      if (!filtered.length) {
        body.innerHTML = '<div style="text-align:center;padding:20px;color:var(--light);">해당 카테고리 지출이 없어요</div>';
        return;
      }

      var total = filtered.reduce(function(s, e) { return s + Number(e.amount || 0); }, 0);

      body.innerHTML = '<div style="background:var(--bg);border-radius:10px;padding:12px 14px;margin-bottom:14px;display:flex;justify-content:space-between;align-items:center;">'
        + '<span style="font-size:12px;color:var(--light);font-weight:600;">' + filtered.length + '건</span>'
        + '<span style="font-size:18px;font-weight:900;color:#1A202C;">₩ ' + total.toLocaleString() + '</span>'
        + '</div>'
        + filtered.map(function(e) {
            var date = e.expenseDate ? String(e.expenseDate).substring(5).replace(/-/g, '/') : '';
            return '<div class="settle-detail-expense-item" style="cursor:pointer;" onclick="closeModal(\'catDetailModal\');openExpenseDetail(' + e.expenseId + ')">'
              + '<div class="settle-detail-expense-item__name">' + _esc(e.description || '') + '</div>'
              + '<div class="settle-detail-expense-item__meta">'
              +   '<span>' + date + ' · 결제: ' + _esc(e.payerNickname || '?') + '</span>'
              +   '<span class="settle-detail-expense-item__share">₩ ' + Number(e.amount || 0).toLocaleString() + '</span>'
              + '</div>'
              + '</div>';
          }).join('');
    })
    .catch(function() {
      body.innerHTML = '<div style="text-align:center;padding:20px;color:var(--light);">불러오기 실패</div>';
    });
}

function _esc(str) {
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

/* ═══════════════════════════════════════════
   DOMContentLoaded — 초기화
═══════════════════════════════════════════ */
document.addEventListener('DOMContentLoaded', function() {

  /* 홈 탭이 기본으로 열리도록 초기 로드 */
  _loadHomeTab();

  /* 결제자 드롭다운 초기값: 나(첫 번째 selected option) */
  var firstSelected = document.querySelector('.exp-payer-option.selected');
  if (firstSelected) {
    var fid   = parseInt(firstSelected.getAttribute('data-id'));
    var fnick = firstSelected.querySelector('.exp-payer-option__name');
    if (fnick) selectPayer(fid, fnick.textContent, true);
  }

  /* addExpenseModal 열릴 때 분담자 초기화 훅 */
  var origOpenModal = typeof openModal === 'function' ? openModal : null;
  document.addEventListener('click', function(e) {
    if (e.target && e.target.getAttribute && e.target.getAttribute('onclick') === "openModal('addExpenseModal')") {
      setTimeout(function() {
        if (_wsParticipants.length === 0) _initParticipants();
        else _renderSplitList();
        _initCatChipDrag();  /* 드래그 스크롤 재초기화 */
      }, 80);
    }
  });

  /* 지출 날짜 기본값: 오늘 */
  var expDateEl = document.getElementById('exp-date');
  if (expDateEl && !expDateEl.value) {
    var today = new Date();
    expDateEl.value = today.getFullYear()
      + '-' + String(today.getMonth() + 1).padStart(2, '0')
      + '-' + String(today.getDate()).padStart(2, '0');
  }

  /* 금액 변경 시 분담 미리보기 갱신 */
  var amtEl = document.getElementById('exp-amt');
  if (amtEl) amtEl.addEventListener('input', recalcSharePreview);

  /* 카테고리 칩 — 마우스 드래그 스크롤 활성화 */
  _initCatChipDrag();
});

function _initCatChipDrag() {
  var el = document.getElementById('expCatChips');
  if (!el) return;
  var isDown = false, startX, scrollLeft;
  el.addEventListener('mousedown', function(e) {
    isDown = true;
    startX    = e.pageX - el.offsetLeft;
    scrollLeft = el.scrollLeft;
    el.style.cursor = 'grabbing';
  });
  el.addEventListener('mouseleave', function() { isDown = false; el.style.cursor = 'grab'; });
  el.addEventListener('mouseup',    function() { isDown = false; el.style.cursor = 'grab'; });
  el.addEventListener('mousemove',  function(e) {
    if (!isDown) return;
    e.preventDefault();
    var x    = e.pageX - el.offsetLeft;
    var walk = (x - startX) * 1.5;
    el.scrollLeft = scrollLeft - walk;
  });
}
