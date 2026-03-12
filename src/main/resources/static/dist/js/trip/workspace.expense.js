/**
 * workspace.expense.js
 * ──────────────────────────────────────────────
 * 담당: 가계부 · 정산 CRUD 전체
 *       ← JSP 인라인 loadExpenseList / submitExpense /
 *          deleteExpenseItem / loadSettlement 이동
 *       ← copyInviteLink 제거 (workspace.ui.js 로 통합)
 *
 * 의존: workspace.ui.js (showToast, openModal, closeModal, normalizeRow)
 *       TRIP_ID, CTX_PATH
 * ──────────────────────────────────────────────
 */

var _CAT_ICON  = { FOOD:'🍽️', ACCOMMODATION:'🏨', TRANSPORT:'🚗', TOUR:'🎯', CAFE:'☕', SHOPPING:'🛍️', ETC:'📦' };
var _CAT_NAME  = { FOOD:'식비', ACCOMMODATION:'숙소', TRANSPORT:'교통', TOUR:'관광', CAFE:'카페', SHOPPING:'쇼핑', ETC:'기타' };
var _CAT_COLOR = {
  ACCOMMODATION:'linear-gradient(135deg,#89CFF0,#B5D8F7)',
  FOOD:         'linear-gradient(135deg,#FFB6C1,#FFCDD5)',
  TRANSPORT:    'linear-gradient(135deg,#C2B8D9,#D9C8E8)',
  TOUR:         'linear-gradient(135deg,#A8C8E1,#BFD9ED)',
  CAFE:         'linear-gradient(135deg,#F6C9A0,#FADA9C)',
  SHOPPING:     'linear-gradient(135deg,#A8E6CF,#B5EDD6)',
  ETC:          'linear-gradient(135deg,#D5D8DC,#E8EAED)'
};

/* ══════════════════════════════
   API 로드 & 렌더
══════════════════════════════ */
function loadExpenseList() {
  fetch(CTX_PATH + '/api/trip/' + TRIP_ID + '/expense')
    .then(function (r) { return r.ok ? r.json() : Promise.reject(r.status); })
    .then(function (list) {
      list = (list || []).map(normalizeRow);

      // 카테고리별 집계
      var catTotals  = {};
      var grandTotal = 0;
      list.forEach(function (e) {
        var k = (e.category || 'ETC').toUpperCase();
        catTotals[k] = (catTotals[k] || 0) + (e.amount || 0);
        grandTotal   += (e.amount || 0);
      });

      // 총액 & 1인당
      var amtEl = document.getElementById('summaryAmt');
      var perEl = document.getElementById('summaryPer');
      if (amtEl) amtEl.textContent = '₩ ' + grandTotal.toLocaleString();
      var memberCnt = Math.max(document.querySelectorAll('.ws-topbar__actions .avatar').length, 1);
      if (perEl) perEl.textContent = '1인당 약 ₩ ' + Math.round(grandTotal / memberCnt).toLocaleString();

      // 카테고리 카드
      var catsEl = document.getElementById('expenseCats');
      if (catsEl) {
        var sorted = Object.keys(catTotals).sort(function (a, b) { return catTotals[b] - catTotals[a]; });
        var top4   = sorted.slice(0, 4);
        if (top4.length === 0) {
          _renderEmptyCats(catsEl);
        } else {
          var maxAmt = catTotals[top4[0]] || 1;
          catsEl.innerHTML = top4.map(function (k) {
            var pct = Math.round(catTotals[k] / maxAmt * 100);
            var bg  = _CAT_COLOR[k] || _CAT_COLOR.ETC;
            return '<div class="expense-cat">'
              + '<span class="expense-cat__icon">' + (_CAT_ICON[k] || '📦') + '</span>'
              + '<span class="expense-cat__name">' + (_CAT_NAME[k] || '기타') + '</span>'
              + '<span class="expense-cat__amt">₩ ' + catTotals[k].toLocaleString() + '</span>'
              + '<div class="expense-cat__bar"><div class="expense-cat__bar-fill" style="width:' + pct + '%;background:' + bg + ';"></div></div>'
              + '</div>';
          }).join('');
        }
      }

      // 지출 리스트
      var listEl = document.getElementById('expenseList');
      if (!listEl) return;
      if (!list || list.length === 0) {
        listEl.innerHTML =
          '<div style="text-align:center;padding:24px 20px;color:#A0AEC0;">' +
          '<div style="font-size:32px;margin-bottom:8px;">💸</div>' +
          '<div style="font-size:13px;font-weight:600;margin-bottom:4px;">아직 지출 내역이 없어요</div>' +
          '<div style="font-size:12px;">+ 지출 추가 버튼으로 기록해보세요</div></div>';
        return;
      }
      listEl.innerHTML = list.slice(0, 10).map(function (e) {
        var k    = (e.category || 'ETC').toUpperCase();
        var icon = _CAT_ICON[k] || '📦';
        var cat  = _CAT_NAME[k] || '기타';
        var priv = e.isPrivate === 'Y' ? '<span class="expense-private-badge">🔒 나만 보기</span>' : '';
        var date = e.expenseDate ? e.expenseDate.substring(5).replace(/-/g, '/') : '';
        return '<div class="expense-item">'
          + '<div class="expense-item__icon-wrap">' + icon + '</div>'
          + '<div class="expense-item__info">'
          + '<div class="expense-item__name">' + (e.description || '') + priv + '</div>'
          + '<div class="expense-item__detail">'
          + '<span>' + date + '</span>'
          + '<span class="expense-payer-chip">💳 ' + (e.payerNickname || '알 수 없음') + '</span>'
          + '<span class="expense-cat-chip">' + icon + ' ' + cat + '</span>'
          + '</div></div>'
          + '<span class="expense-item__amt">₩ ' + (e.amount || 0).toLocaleString() + '</span>'
          + '<button class="expense-del-btn" onclick="deleteExpenseItem(' + e.expenseId + ')" title="삭제">✕</button>'
          + '</div>';
      }).join('');
    })
    .catch(function (err) {
      console.warn('[Expense] 로드 실패:', err);
      var catsEl = document.getElementById('expenseCats');
      if (catsEl) _renderEmptyCats(catsEl);
      var listEl = document.getElementById('expenseList');
      if (listEl) listEl.innerHTML =
        '<div style="text-align:center;padding:16px;color:#bbb;font-size:13px">지출 내역을 불러오지 못했어요</div>';
    });
}

function _renderEmptyCats(el) {
  var order = ['ACCOMMODATION', 'FOOD', 'TRANSPORT', 'TOUR'];
  el.innerHTML = order.map(function (k) {
    return '<div class="expense-cat">'
      + '<span class="expense-cat__icon">' + _CAT_ICON[k] + '</span>'
      + '<span class="expense-cat__name">' + _CAT_NAME[k] + '</span>'
      + '<span class="expense-cat__amt" style="color:#CBD5E0;">₩ 0</span>'
      + '<div class="expense-cat__bar"><div class="expense-cat__bar-fill" style="width:0%"></div></div>'
      + '</div>';
  }).join('');
}

/* ══════════════════════════════
   지출 추가 (POST)
══════════════════════════════ */
function submitExpense() {
  var name    = document.getElementById('exp-name').value.trim();
  var amt     = parseFloat(document.getElementById('exp-amt').value) || 0;
  var cat     = document.getElementById('exp-cat').value;
  var payerEl = document.getElementById('exp-payer');
  var payer   = payerEl ? payerEl.value : null;
  var date    = document.getElementById('exp-date').value;
  var isPriv  = document.getElementById('exp-private').checked ? 'Y' : 'N';

  if (!name)    { alert('항목명을 입력해주세요'); return; }
  if (amt <= 0) { alert('금액을 입력해주세요');  return; }
  if (!date)    { alert('날짜를 선택해주세요');  return; }

  var btn = document.querySelector('#addExpenseModal .btn-primary');
  if (btn) { btn.disabled = true; btn.textContent = '추가 중...'; }

  fetch(CTX_PATH + '/api/trip/' + TRIP_ID + '/expense', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      description:          name,
      amount:               amt,
      category:             cat,
      payerId:              payer ? parseInt(payer) : null,
      expenseDate:          date,
      isPrivate:            isPriv,
      participantMemberIds: payer ? [parseInt(payer)] : []
    })
  })
  .then(function (r) { return r.json(); })
  .then(function (d) {
    if (d.success) {
      closeModal('addExpenseModal');
      document.getElementById('exp-name').value     = '';
      document.getElementById('exp-amt').value      = '';
      document.getElementById('exp-private').checked = false;
      showToast('💸 지출이 추가됐어요!');
      loadExpenseList();
      loadSettlement();
    } else {
      alert(d.message || '추가 실패');
    }
  })
  .catch(function (e) {
    console.error('[Expense] 추가 실패', e);
    showToast('⚠️ 지출 추가에 실패했어요');
  })
  .finally(function () {
    if (btn) { btn.disabled = false; btn.textContent = '지출 추가하기'; }
  });
}

/* ══════════════════════════════
   지출 삭제 (DELETE)
══════════════════════════════ */
function deleteExpenseItem(expenseId) {
  if (!confirm('이 지출을 삭제할까요?')) return;
  fetch(CTX_PATH + '/api/trip/' + TRIP_ID + '/expense/' + expenseId, { method: 'DELETE' })
    .then(function (r) { return r.json(); })
    .then(function (d) {
      if (d.success) {
        loadExpenseList();
        loadSettlement();
        showToast('🗑️ 지출이 삭제됐어요');
      } else {
        alert(d.message || '삭제 실패');
      }
    })
    .catch(function () { showToast('⚠️ 삭제에 실패했어요'); });
}

/* ══════════════════════════════
   정산 현황 (POST)
══════════════════════════════ */
function loadSettlement() {
  var el = document.getElementById('settleList');
  if (!el) return;

  fetch(CTX_PATH + '/api/trip/' + TRIP_ID + '/settlement/calculate', { method: 'POST' })
    .then(function (r) { return r.ok ? r.json() : Promise.reject(r.status); })
    .then(function (list) {
      if (!list || list.length === 0) {
        el.innerHTML = '<div style="text-align:center;padding:16px;color:#999;font-size:13px">정산할 내역이 없어요 ✨</div>';
        return;
      }
      el.innerHTML = list.map(function (s) {
        var fromLabel = s.fromNickname || '?';
        var toLabel   = s.toNickname   || '?';
        var amt       = (s.amount || 0).toLocaleString();
        return '<div class="settle-item">'
          + '<span class="settle-from">' + fromLabel + '</span>'
          + '<svg style="margin:0 6px;opacity:.5" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>'
          + '<span class="settle-to">' + toLabel + '</span>'
          + '<span class="settle-amt">₩ ' + amt + '</span>'
          + '</div>';
      }).join('');
    })
    .catch(function () {
      el.innerHTML = '<div style="text-align:center;padding:12px;color:#bbb;font-size:12px">정산 정보를 불러오지 못했어요</div>';
    });
}

/* ══════════════════════════════
   정산 요청 (PATCH)
══════════════════════════════ */
function requestSettle(btn, participantId) {
  if (!participantId) { showToast('⚠️ 정산 대상 정보가 없어요'); return; }
  btn.disabled = true;
  btn.textContent = '📨 요청 중...';

  fetch(CTX_PATH + '/api/trip/' + TRIP_ID + '/expense/settle', {
    method: 'PATCH',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ participantId: participantId })
  })
  .then(function (r) { return r.json(); })
  .then(function (d) {
    if (d.success) {
      btn.textContent      = '✅ 정산 완료';
      btn.style.borderColor = '#89CFF0';
      btn.style.color       = '#3a8fb7';
      btn.style.background  = 'rgba(137,207,240,.08)';
      showToast('📨 정산 요청을 보냈어요!');
    } else {
      btn.disabled = false; btn.textContent = '정산 요청';
      showToast('⚠️ 정산 요청 실패');
    }
  })
  .catch(function () {
    btn.disabled = false; btn.textContent = '정산 요청';
    showToast('⚠️ 서버 오류');
  });
}

/* ══════════════════════════════
   자동 초기 로드
══════════════════════════════ */
document.addEventListener('DOMContentLoaded', function () {
  loadExpenseList();
  loadSettlement();

  // 지출 날짜 기본값: 오늘
  var expDateEl = document.getElementById('exp-date');
  if (expDateEl) {
    var today = new Date();
    var yy = today.getFullYear();
    var mm = String(today.getMonth() + 1).padStart(2, '0');
    var dd = String(today.getDate()).padStart(2, '0');
    expDateEl.value = yy + '-' + mm + '-' + dd;
  }
});
