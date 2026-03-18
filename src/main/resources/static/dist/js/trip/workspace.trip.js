/**
 * workspace.trip.js
 * ─────────────────────────────────────────
 * 담당: 여행 정보 수정 모달 + 썸네일 편집 + 태그 편집 + 여행 삭제
/* ══════════════════════════════
   썸네일 편집 전역 상태
══════════════════════════════ */
var _editThumbBase64 = null; // null=변경없음 / 'DEFAULT'=기본이미지 / 'data:...'=새이미지

function onEditThumbChange(event) {
  var file = event.target.files[0];
  if (!file) return;
  if (file.size > 5 * 1024 * 1024) { alert('이미지 크기는 5MB 이하여야 해요'); return; }
  var reader = new FileReader();
  reader.onload = function(e) {
    _editThumbBase64 = e.target.result;
    document.getElementById('editThumbPreview').src = e.target.result;
    var resetBtn = document.getElementById('editThumbResetBtn');
    if (resetBtn) resetBtn.style.display = '';
  };
  reader.readAsDataURL(file);
}

function resetEditThumb() {
  _editThumbBase64 = 'DEFAULT';
  var ctx = typeof CTX_PATH !== 'undefined' ? CTX_PATH : '';
  document.getElementById('editThumbPreview').src = ctx + '/dist/images/logo.png';
  document.getElementById('editThumbInput').value = '';
  var resetBtn = document.getElementById('editThumbResetBtn');
  if (resetBtn) resetBtn.style.display = 'none';
}

/* ══════════════════════════════
   태그 편집
══════════════════════════════ */
function handleEditTagInput(e) {
  if (e.key === 'Enter' || e.key === ',') {
    e.preventDefault();
    var val = e.target.value.trim().replace(/^#/, '');
    if (val) addEditTag(val);
    e.target.value = '';
  }
}

function addEditTag(name) {
  var wrap = document.getElementById('editTagWrap');
  if (!wrap) return;
  var tag = name.startsWith('#') ? name : '#' + name;
  var exists = Array.from(wrap.querySelectorAll('.edit-tag-chip'))
    .some(function(c) { return c.dataset.tag === tag; });
  if (exists) return;
  if (wrap.querySelectorAll('.edit-tag-chip').length >= 10) {
    alert('태그는 최대 10개까지 추가할 수 있어요.'); return;
  }
  var chip = document.createElement('span');
  chip.className = 'edit-tag-chip';
  chip.dataset.tag = tag;
  chip.innerHTML = tag + '<button type="button" onclick="removeEditTag(this)" title="삭제">✕</button>';
  var input = document.getElementById('editTagInput');
  wrap.insertBefore(chip, input);
}

function removeEditTag(btn) { btn.closest('.edit-tag-chip').remove(); }

function addEditTagPreset(el) { addEditTag(el.textContent.replace(/^#/, '')); }

function _getEditTags() {
  var wrap = document.getElementById('editTagWrap');
  if (!wrap) return [];
  return Array.from(wrap.querySelectorAll('.edit-tag-chip'))
    .map(function(c) { return c.dataset.tag || c.textContent.replace('✕','').trim(); });
}

/* ══════════════════════════════
   모달 열기
══════════════════════════════ */
function openTripEditModal() {
  _editThumbBase64 = null;
  var meta = (typeof TRIP_META !== 'undefined') ? TRIP_META : {};

  _setVal('editTripTitle',  meta.tripName    || '');
  _setVal('editTripDesc',   meta.description || '');
  _setVal('editStartDate',  meta.origStart   || '');
  _setVal('editEndDate',    meta.origEnd     || '');
  _setVal('editTripType',   meta.tripType    || '');

  var countEl = document.getElementById('editDescCount');
  if (countEl) countEl.textContent = (meta.description || '').length;

  var warnEl = document.getElementById('editDateWarning');
  if (warnEl) warnEl.style.display = 'none';

  document.querySelectorAll('.edit-type-btn').forEach(function(b) {
    var typeMap = {
      '💑 커플':'COUPLE','👨‍👩‍👧 가족':'FAMILY','🤝 친구':'FRIENDS','🧳 혼자':'SOLO','💼 비즈니스':'BUSINESS',
      '커플':'COUPLE','가족':'FAMILY','친구':'FRIENDS','혼자':'SOLO','비즈니스':'BUSINESS'
    };
    b.classList.toggle('active', typeMap[b.textContent.trim()] === meta.tripType);
  });

  var preview = document.getElementById('editThumbPreview');
  if (preview && meta.thumbnailUrl) {
    var ctx = typeof CTX_PATH !== 'undefined' ? CTX_PATH : '';
    preview.src = meta.thumbnailUrl.startsWith('http') ? meta.thumbnailUrl : ctx + meta.thumbnailUrl;
  }
  var resetBtn = document.getElementById('editThumbResetBtn');
  if (resetBtn) resetBtn.style.display = 'none';

  openModal('tripEditModal');
}

function _setVal(id, val) {
  var el = document.getElementById(id);
  if (el) el.value = val;
}

function selectEditType(type, el) {
  if (typeof TRIP_META !== 'undefined') TRIP_META.tripType = type;
  _setVal('editTripType', type);
  document.querySelectorAll('.edit-type-btn').forEach(function(b) { b.classList.remove('active'); });
  el.classList.add('active');
}

/* ══════════════════════════════════════════════
   날짜 변경 경고 — Day(일차) 기준 3케이스

   핵심 원칙: 장소는 '날짜'가 아닌 'Day 순서'에 종속된다.
   → 날짜가 완전히 달라져도 Day 수가 같으면 일정 유지
   → 비교 기준은 총 일차 수(Duration), 날짜 겹침이 아님
══════════════════════════════════════════════ */
function checkEditDateWarning() {
  var meta   = (typeof TRIP_META !== 'undefined') ? TRIP_META : {};
  var newS   = (document.getElementById('editStartDate') || {}).value;
  var newE   = (document.getElementById('editEndDate')   || {}).value;
  var warnEl = document.getElementById('editDateWarning');
  if (!warnEl) return;
  if (!newS || !newE) { warnEl.style.display = 'none'; return; }

  var ns = _d(newS), ne = _d(newE);

  // 기본 유효성: 종료일 < 시작일 불가
  if (ns > ne) {
    return _warn(warnEl, ' 종료일이 시작일보다 빠를 수 없어요.', 'warn-error');
  }

  // 날짜 미변경
  if (newS === meta.origStart && newE === meta.origEnd) {
    warnEl.style.display = 'none'; return;
  }

  var oldDays = _calcDays(meta.origStart, meta.origEnd);
  var newDays = _calcDays(newS, newE);

  if (oldDays === 0 || newDays === 0) { warnEl.style.display = 'none'; return; }

  /* ── Case 1: 일수 감소 → 후순위 일차 삭제 경고 ── */
  if (newDays < oldDays) {
    var deletedDays = oldDays - newDays;
    var deleteRange = deletedDays === 1
      ? 'Day ' + oldDays
      : 'Day ' + (newDays + 1) + '~' + oldDays;
    return _warn(
      warnEl,
      ' 여행 기간이 줄어들었어요. <strong>' + deleteRange + '의 일정(장소·메모·사진)이 영구 삭제</strong>됩니다. ' +
      '저장 전 꼭 확인해 주세요.',
      'warn-danger'
    );
  }

  /* ── Case 2: 일수 증가 → 기존 유지 + 새 일차 추가 ── */
  if (newDays > oldDays) {
    var addedDays = newDays - oldDays;
    var addRange = addedDays === 1
      ? 'Day ' + newDays + ' 1일차'
      : 'Day ' + (oldDays + 1) + '~' + newDays + ' ' + addedDays + '일차';
    return _warn(
      warnEl,
      ' 기존 일정(Day 1~' + oldDays + ')은 <strong>그대로 유지</strong>돼요. ' +
      '<strong>' + addRange + '가 새로 추가</strong>됩니다.',
      'warn-info'
    );
  }

  /* ── Case 3: 일수 동일, 날짜만 이동 ── */
  return _warn(
    warnEl,
    ' 여행 날짜가 변경돼요. 기존에 짜둔 <strong>일정은 그대로 새 날짜로 이동</strong>됩니다.',
    'warn-info'
  );
}

/** YYYY-MM-DD 두 문자열 사이 총 일수(당일 포함) */
function _calcDays(startStr, endStr) {
  if (!startStr || !endStr) return 0;
  var s = _d(startStr), e = _d(endStr);
  if (s > e) return 0;
  return Math.round((e - s) / 86400000) + 1;
}

function _d(str) { var d = new Date(str); d.setHours(0, 0, 0, 0); return d; }

function _warn(el, html, cls) {
  el.innerHTML = html;
  el.className = 'edit-date-warning ' + cls;
  el.style.display = 'block';
}

/* ══════════════════════════════════════════════
   여행 정보 저장 (PATCH)

   confirm 분기:
   - warn-error   → 저장 불가 (return)
   - warn-danger  → 삭제 확인 팝업 (취소 가능)
   - warn-info    → 안내만이므로 confirm 없이 진행
══════════════════════════════════════════════ */
function submitTripEdit() {
  var title    = (document.getElementById('editTripTitle') || {}).value || '';
  var desc     = (document.getElementById('editTripDesc')  || {}).value || '';
  var startD   = (document.getElementById('editStartDate') || {}).value || '';
  var endD     = (document.getElementById('editEndDate')   || {}).value || '';
  var type     = (document.getElementById('editTripType')  || {}).value || '';
  var isPublic = document.getElementById('editIsPublic') && document.getElementById('editIsPublic').checked ? 1 : 0;
  var tags     = _getEditTags();

  title = title.trim(); desc = desc.trim();
  if (!title)           { alert('여행 제목을 입력해 주세요.');         return; }
  if (!startD || !endD) { alert('날짜를 입력해 주세요.');              return; }
  if (startD > endD)    { alert('종료일이 시작일보다 빠를 수 없어요.'); return; }

  var warn = document.getElementById('editDateWarning');
  if (warn && warn.style.display !== 'none') {
    var cls = warn.className;

    // warn-error: 저장 불가
    if (cls.indexOf('warn-error') >= 0) {
      alert('날짜를 올바르게 입력해 주세요.');
      return;
    }

    if (cls.indexOf('warn-danger') >= 0) {
      var meta = (typeof TRIP_META !== 'undefined') ? TRIP_META : {};
      var oldDays = _calcDays(meta.origStart, meta.origEnd);
      var newDays = _calcDays(startD, endD);
      var deletedDays = oldDays - newDays;
      var deleteRange = deletedDays === 1
        ? 'Day ' + oldDays
        : 'Day ' + (newDays + 1) + '~' + oldDays;
      if (!confirm(
        '🚨 일정 삭제 확인\n\n' +
        deleteRange + '의 장소·메모·사진이\n영구 삭제됩니다.\n\n계속 진행하시겠습니까?'
      )) return;
    }
  }

  var btn = document.getElementById('btnEditSave');
  if (btn) { btn.disabled = true; btn.textContent = '저장 중…'; }

  var thumbPayload = null;
  if (_editThumbBase64 === 'DEFAULT') thumbPayload = '';
  else if (_editThumbBase64 !== null) thumbPayload = _editThumbBase64;

  fetch(CTX_PATH + '/trip/' + TRIP_ID, {
    method: 'PATCH',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      title:           title,
      tripName:        title,
      description:     desc,
      startDate:       startD,  
      endDate:         endD,   
      tripType:        type,
      isPublic:        isPublic,
      tags:            tags,
      thumbnailBase64: thumbPayload,
      cities:          null
    })
  })
  .then(function(r) { return r.json(); })
  .then(function(d) {
    if (d.success) { closeModal('tripEditModal'); location.reload(); }
    else {
      alert('수정 실패: ' + (d.message || '오류가 발생했습니다.'));
      if (btn) { btn.disabled = false; btn.textContent = '저장하기'; }
    }
  })
  .catch(function() {
    alert('네트워크 오류가 발생했습니다. 다시 시도해 주세요.');
    if (btn) { btn.disabled = false; btn.textContent = '저장하기'; }
  });
}

/* ══════════════════════════════
   여행 삭제 (DELETE)
══════════════════════════════ */
function confirmDeleteTrip() {
  var tripName = (typeof TRIP_META !== 'undefined' && TRIP_META.tripName) ? TRIP_META.tripName : '이 여행';
  if (!confirm(
    '⚠️ 여행을 삭제하면 되돌릴 수 없습니다!\n\n삭제 대상: ' + tripName +
    '\n\n• 등록된 모든 일정(장소·메모·사진)\n• 체크리스트, 투표, 예산 내역\n• 동행자 정보 및 초대 기록\n\n위 데이터가 모두 삭제됩니다. 계속하시겠습니까?'
  )) return;

  var btn = document.getElementById('btnDeleteTrip');
  if (btn) { btn.disabled = true; btn.textContent = '삭제 중…'; }

  fetch(CTX_PATH + '/trip/' + TRIP_ID, {
    method: 'DELETE',
    headers: { 'Content-Type': 'application/json' }
  })
  .then(function(r) { return r.json(); })
  .then(function(d) {
    if (d.success) {
      alert('여행이 삭제되었습니다.');
      window.location.href = CTX_PATH + '/trip/my_trips';
    } else {
      alert('삭제 실패: ' + (d.message || '오류가 발생했습니다.'));
      if (btn) { btn.disabled = false; btn.textContent = '여행 삭제'; }
    }
  })
  .catch(function() {
    alert('네트워크 오류가 발생했습니다. 다시 시도해 주세요.');
    if (btn) { btn.disabled = false; btn.textContent = '여행 삭제'; }
  });
}
