/**
 * workspace.checklist.js
 * ──────────────────────────────────────────────
 * 담당: 체크리스트 CRUD 전체
 *       ← JSP 인라인 loadChecklist / renderChecklist /
 *          openCheckModal / submitCheckItem / toggleCheckItem /
 *          deleteCheckItem 이동 + 기존 인라인 추가 UI 통합
 *
 * 의존: workspace.ui.js (showToast, openModal, closeModal, normalizeRow)
 *       TRIP_ID, CTX_PATH
 * ──────────────────────────────────────────────
 */

/* ══════════════════════════════
   API 로드 & 렌더
══════════════════════════════ */
function loadChecklist() {
  fetch(CTX_PATH + '/api/trip/' + TRIP_ID + '/checklist')
    .then(function (r) { return r.ok ? r.json() : Promise.reject(r.status); })
    .then(function (list) { renderChecklist((list || []).map(normalizeRow)); })
    .catch(function () {
      var grid = document.getElementById('checkGrid');
      if (grid) grid.innerHTML =
        '<div style="grid-column:1/-1;text-align:center;padding:20px;color:#bbb;font-size:13px">체크리스트를 불러오지 못했어요</div>';
    });
}

function renderChecklist(list) {
  var grid = document.getElementById('checkGrid');
  if (!grid) return;

  if (!list || list.length === 0) {
    grid.innerHTML =
      '<div id="checkEmpty" style="grid-column:1/-1;text-align:center;padding:40px 20px;color:#A0AEC0;">' +
      '<div style="font-size:36px;margin-bottom:10px;">📋</div>' +
      '<div style="font-size:14px;font-weight:600;margin-bottom:4px;">준비물이 없어요</div>' +
      '<div style="font-size:12px;">+ 추가 버튼으로 항목을 만들어보세요</div></div>';
    _updateCheckProgress(0, 0);
    return;
  }

  // 카테고리별 그룹핑
  var groups = {};
  list.forEach(function (item) {
    var cat = item.category || '기타';
    if (!groups[cat]) groups[cat] = [];
    groups[cat].push(item);
  });

  var total   = list.length;
  var checked = list.filter(function (i) { return i.isChecked === 1 || i.isChecked === true; }).length;
  _updateCheckProgress(checked, total);

  var catEmoji = {
    '서류 & 결제':'📋', '의류 & 용품':'👗', '의약품':'💊', '전자기기':'📱', '기타':'📦'
  };

  var html = '';
  Object.keys(groups).forEach(function (cat) {
    var emoji = catEmoji[cat] || '📦';
    html += '<div class="check-category" id="cat-' + encodeURIComponent(cat) + '">'
      + '<div class="check-cat-label">'
      + '<span class="check-cat-label-left">' + emoji + ' ' + cat + '</span>'
      + '<button class="check-cat-add" onclick="openInlineAdd(\'cat-' + encodeURIComponent(cat) + '\')">+ 항목</button>'
      + '</div>'
      + '<div class="check-add-row" id="add-row-cat-' + encodeURIComponent(cat) + '">'
      + '<input type="text" class="check-add-input" placeholder="항목 입력…"'
      + ' onkeydown="checkAddKeydown(event,\'cat-' + encodeURIComponent(cat) + '\')">'
      + '<button class="check-add-confirm" onclick="confirmInlineAdd(\'cat-' + encodeURIComponent(cat) + '\')">추가</button>'
      + '<button class="check-add-cancel" onclick="cancelInlineAdd(\'cat-' + encodeURIComponent(cat) + '\')">취소</button>'
      + '</div>';

    groups[cat].forEach(function (item) {
      var done    = (item.isChecked === 1 || item.isChecked === true) ? ' done' : '';
      var mgrHtml = item.checkManager
        ? '<span class="check-by">' + item.checkManager + '</span>' : '';
      html += '<div class="check-item' + done + '" data-id="' + item.checklistId + '" id="ci-' + item.checklistId + '">'
        + '<input type="checkbox" id="chk' + item.checklistId + '"' + (done ? ' checked' : '')
        + ' onchange="toggleCheckItem(' + item.checklistId + ',this)">'
        + '<label for="chk' + item.checklistId + '">' + item.itemName + '</label>'
        + mgrHtml
        + '<button class="check-item-del" onclick="event.stopPropagation();deleteCheckItem(' + item.checklistId + ')" title="삭제">✕</button>'
        + '</div>';
    });
    html += '</div>';
  });

  html += '<button class="check-category-add-card" onclick="openCheckModal()">'
    + '<span style="font-size:22px">+</span><span>항목 추가</span></button>';
  grid.innerHTML = html;
}

function _updateCheckProgress(checked, total) {
  var pct = total === 0 ? 0 : Math.round(checked / total * 100);
  var bar = document.getElementById('checkProgressBar');
  var txt = document.getElementById('checkProgressTxt');
  if (bar) bar.style.width = pct + '%';
  if (txt) txt.textContent = checked + ' / ' + total + ' 완료';
}

// 외부 호출용 alias (ws.js 등에서 호출)
function updateCheckProgress() {
  var all  = document.querySelectorAll('#checkGrid .check-item').length;
  var done = document.querySelectorAll('#checkGrid .check-item.done').length;
  _updateCheckProgress(done, all);
}

/* ══════════════════════════════
   모달 열기 (헤더 + 추가 버튼)
══════════════════════════════ */
function openCheckModal() {
  var nameEl = document.getElementById('chk-itemName');
  var mgrEl  = document.getElementById('chk-manager');
  var catEl  = document.getElementById('chk-category');
  var newEl  = document.getElementById('chk-categoryNew');
  if (nameEl) nameEl.value = '';
  if (mgrEl)  mgrEl.value  = '';
  if (catEl)  { catEl.value = '서류 & 결제'; catEl.style.display = ''; }
  if (newEl)  newEl.style.display = 'none';
  openModal('addCheckModal');
}
// alias
function openAddCheckModal() { openCheckModal(); }

function toggleCustomCategory() {
  var sel = document.getElementById('chk-category');
  var inp = document.getElementById('chk-categoryNew');
  var btn = document.getElementById('btnToggleCat');
  if (inp.style.display === 'none') {
    inp.style.display = ''; sel.style.display = 'none'; inp.focus();
    if (btn) { btn.textContent = '선택으로'; btn.classList.add('active'); }
  } else {
    inp.style.display = 'none'; sel.style.display = '';
    if (btn) { btn.textContent = '직접입력'; btn.classList.remove('active'); }
  }
}

/* ══════════════════════════════
   모달 추가 (POST)
══════════════════════════════ */
function submitCheckItem() {
  var itemName = document.getElementById('chk-itemName').value.trim();
  if (!itemName) { alert('항목 이름을 입력해주세요'); return; }

  var selEl    = document.getElementById('chk-category');
  var newEl    = document.getElementById('chk-categoryNew');
  var category = (newEl.style.display !== 'none' && newEl.value.trim())
    ? newEl.value.trim() : selEl.value;
  var manager  = document.getElementById('chk-manager').value.trim();

  fetch(CTX_PATH + '/api/trip/' + TRIP_ID + '/checklist', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ itemName: itemName, category: category, checkManager: manager || null })
  })
  .then(function (r) { return r.json(); })
  .then(function (data) {
    if (data.success) {
      closeModal('addCheckModal');
      loadChecklist();
      showToast('✅ ' + itemName + ' 추가됨!');
    } else {
      alert(data.message || '추가 실패');
    }
  })
  .catch(function () { alert('서버 오류가 발생했어요'); });
}

/* ══════════════════════════════
   체크박스 토글 (PATCH) — 낙관적 업데이트
══════════════════════════════ */
function toggleCheckItem(checklistId, checkbox) {
  var row = document.getElementById('ci-' + checklistId);
  if (row) row.classList.toggle('done', checkbox.checked);

  fetch(CTX_PATH + '/api/trip/' + TRIP_ID + '/checklist/' + checklistId + '/toggle', {
    method: 'PATCH'
  })
  .then(function (r) { return r.json(); })
  .then(function () { loadChecklist(); })
  .catch(function () { loadChecklist(); });
}

/* toggleCheck: 기존 checklist.js의 onclick 방식용 (data-id 기반) */
function toggleCheck(item) {
  var checklistId = item.getAttribute('data-id');
  if (!checklistId) {
    var cb = item.querySelector('input[type=checkbox]');
    if (cb) { cb.checked = !cb.checked; item.classList.toggle('done', cb.checked); }
    updateCheckProgress();
    return;
  }
  var cb = item.querySelector('input[type=checkbox]');
  if (cb) { cb.checked = !cb.checked; item.classList.toggle('done', cb.checked); }
  updateCheckProgress();

  fetch(CTX_PATH + '/api/trip/' + TRIP_ID + '/checklist/' + checklistId + '/toggle', {
    method: 'PATCH'
  })
  .then(function (r) { if (!r.ok) throw new Error('fail'); })
  .catch(function () {
    if (cb) { cb.checked = !cb.checked; item.classList.toggle('done', cb.checked); }
    updateCheckProgress();
    showToast('⚠️ 저장에 실패했어요');
  });
}

/* ══════════════════════════════
   삭제 (DELETE)
══════════════════════════════ */
function deleteCheckItem(checklistId) {
  if (!confirm('항목을 삭제할까요?')) return;
  fetch(CTX_PATH + '/api/trip/' + TRIP_ID + '/checklist/' + checklistId, { method: 'DELETE' })
    .then(function () { loadChecklist(); showToast('🗑 항목이 삭제됐어요'); });
}

// onclick 버튼 방식 alias (기존 checklist.js)
function delCheckItem(btn) {
  var item = btn.closest('.check-item');
  var id   = item ? item.getAttribute('data-id') : null;
  if (!id) { if (item) item.remove(); updateCheckProgress(); return; }
  deleteCheckItem(id);
}

/* ══════════════════════════════
   인라인 추가 UI (카테고리 내 직접 입력)
══════════════════════════════ */
function openInlineAdd(catId) {
  document.querySelectorAll('.check-add-row.open').forEach(function (r) {
    r.classList.remove('open');
    var inp = r.querySelector('.check-add-input');
    if (inp) inp.value = '';
  });
  var row = document.getElementById('add-row-' + catId);
  if (row) { row.classList.add('open'); row.querySelector('.check-add-input').focus(); }
}

function cancelInlineAdd(catId) {
  var row = document.getElementById('add-row-' + catId);
  if (row) { row.classList.remove('open'); row.querySelector('.check-add-input').value = ''; }
}

function confirmInlineAdd(catId) {
  var row   = document.getElementById('add-row-' + catId);
  var input = row ? row.querySelector('.check-add-input') : null;
  if (!input) return;
  var val = input.value.trim();
  if (!val) { input.focus(); return; }

  var catEl    = document.getElementById(catId);
  var catLabel = catEl ? catEl.querySelector('.check-cat-label-left') : null;
  var catName  = catLabel ? catLabel.textContent.replace(/^[^\s]+\s*/, '').trim() : '기타';

  input.disabled = true;
  fetch(CTX_PATH + '/api/trip/' + TRIP_ID + '/checklist', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      itemName:     val,
      category:     catName || '기타',
      checkManager: (typeof MY_NICK !== 'undefined') ? MY_NICK : null
    })
  })
  .then(function (r) { return r.json(); })
  .then(function (d) {
    input.disabled = false;
    if (d.success) {
      input.value = ''; input.focus();
      showToast('✅ 항목 추가됨');
      loadChecklist();
    } else {
      showToast('⚠️ ' + (d.message || '추가 실패'));
    }
  })
  .catch(function () { input.disabled = false; showToast('⚠️ 서버 오류'); });
}

function checkAddKeydown(e, catId) {
  if (e.key === 'Enter')  confirmInlineAdd(catId);
  if (e.key === 'Escape') cancelInlineAdd(catId);
}

/* 새 카테고리 추가 */
function addNewCategory() {
  var name = prompt('카테고리 이름을 입력하세요 (예: 🧴 세면도구)');
  if (!name || !name.trim()) return;
  var catId   = 'cat-' + Date.now();
  var addCard = document.querySelector('.check-category-add-card');
  var cat     = document.createElement('div');
  cat.className = 'check-category';
  cat.id = catId;
  cat.innerHTML =
    '<div class="check-cat-label">' +
      '<span class="check-cat-label-left">' + name.trim() + '</span>' +
      '<button class="check-cat-add" onclick="openInlineAdd(\'' + catId + '\')">+ 항목</button>' +
    '</div>' +
    '<div class="check-add-row open" id="add-row-' + catId + '">' +
      '<input type="text" class="check-add-input" placeholder="첫 항목 입력…"' +
      ' onkeydown="checkAddKeydown(event,\'' + catId + '\')">' +
      '<button class="check-add-confirm" onclick="confirmInlineAdd(\'' + catId + '\')">추가</button>' +
      '<button class="check-add-cancel"  onclick="cancelInlineAdd(\'' + catId + '\')">취소</button>' +
    '</div>';
  if (addCard) addCard.parentNode.insertBefore(cat, addCard);
  setTimeout(function () { cat.querySelector('.check-add-input').focus(); }, 50);
  showToast('📋 카테고리 추가됨');
}

/* ══════════════════════════════
   자동 초기 로드
══════════════════════════════ */
document.addEventListener('DOMContentLoaded', function () {
  loadChecklist();
});
