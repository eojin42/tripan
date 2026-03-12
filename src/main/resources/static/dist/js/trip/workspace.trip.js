/**
 * workspace.trip.js  ★ NEW
 * ──────────────────────────────────────────────
 * 담당: 여행 기본 정보 편집 모달
 *       ← JSP 인라인 openTripEditModal / selectEditType /
 *          checkEditDateWarning / submitTripEdit 이동
 *
 * JSP에서 주입해야 할 전역 변수 (아래 workspace.jsp 참고):
 *   TRIP_META = {
 *     tripName:    '...',
 *     description: '...',
 *     tripType:    '...',
 *     origStart:   'YYYY-MM-DD',
 *     origEnd:     'YYYY-MM-DD'
 *   }
 *
 * 의존: workspace.ui.js (showToast, openModal, closeModal)
 *       TRIP_ID, CTX_PATH
 * ──────────────────────────────────────────────
 */

/* ══════════════════════════════
   모달 열기
══════════════════════════════ */
function openTripEditModal() {
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

  // 여행 유형 버튼 active 복원
  document.querySelectorAll('.edit-type-btn').forEach(function (b) {
    b.classList.toggle('active', b.textContent.trim() === _getTripTypeLabel(meta.tripType));
  });

  openModal('tripEditModal');
}

function _setVal(id, val) {
  var el = document.getElementById(id);
  if (el) el.value = val;
}

function _getTripTypeLabel(type) {
  var map = { COUPLE:'커플', FAMILY:'가족', FRIENDS:'친구', SOLO:'혼자', BUSINESS:'비즈니스' };
  return map[type] || '';
}

function selectEditType(type, el) {
  if (typeof TRIP_META !== 'undefined') TRIP_META.tripType = type;
  _setVal('editTripType', type);
  document.querySelectorAll('.edit-type-btn').forEach(function (b) { b.classList.remove('active'); });
  el.classList.add('active');
}

/* ══════════════════════════════
   날짜 변경 경고 (실시간)
══════════════════════════════ */
function checkEditDateWarning() {
  var meta  = (typeof TRIP_META !== 'undefined') ? TRIP_META : {};
  var newS  = (document.getElementById('editStartDate') || {}).value;
  var newE  = (document.getElementById('editEndDate')   || {}).value;
  var warnEl = document.getElementById('editDateWarning');
  if (!warnEl) return;
  if (!newS || !newE) { warnEl.style.display = 'none'; return; }

  var os = _d(meta.origStart), oe = _d(meta.origEnd);
  var ns = _d(newS),           ne = _d(newE);

  if (ns > ne) {
    return _warn(warnEl, '⚠️ 종료일이 시작일보다 빠를 수 없어요.', 'warn-error');
  }
  if ((ne < os) || (ns > oe)) {
    return _warn(warnEl, '🚨 기존 날짜와 겹치지 않아요. 저장 시 <strong>등록된 장소가 모두 초기화</strong>됩니다.', 'warn-danger');
  }
  if (ne < oe) {
    return _warn(warnEl, '📋 종료일이 줄었어요. <strong>삭제되는 날짜의 일정이 제거</strong>됩니다.', 'warn-caution');
  }
  if (ns > os) {
    return _warn(warnEl, '📋 시작일이 늦어졌어요. <strong>삭제되는 날짜의 일정이 제거</strong>됩니다.', 'warn-caution');
  }
  warnEl.style.display = 'none';
}

function _d(str) {
  var d = new Date(str); d.setHours(0, 0, 0, 0); return d;
}
function _warn(el, html, cls) {
  el.innerHTML = html;
  el.className = 'edit-date-warning ' + cls;
  el.style.display = 'block';
}

/* ══════════════════════════════
   여행 정보 저장 (PATCH)
══════════════════════════════ */
function submitTripEdit() {
  var title    = (document.getElementById('editTripTitle') || {}).value || '';
  var desc     = (document.getElementById('editTripDesc')  || {}).value || '';
  var startD   = (document.getElementById('editStartDate') || {}).value || '';
  var endD     = (document.getElementById('editEndDate')   || {}).value || '';
  var type     = (document.getElementById('editTripType')  || {}).value || '';
  var isPublic = document.getElementById('editIsPublic') && document.getElementById('editIsPublic').checked ? 1 : 0;

  title  = title.trim(); desc = desc.trim();
  if (!title)          { alert('여행 제목을 입력해 주세요.');   return; }
  if (!startD || !endD){ alert('날짜를 입력해 주세요.');        return; }
  if (startD > endD)   { alert('종료일이 시작일보다 빠를 수 없어요.'); return; }

  var warn = document.getElementById('editDateWarning');
  if (warn && warn.style.display !== 'none') {
    if (warn.className.indexOf('warn-danger') >= 0) {
      if (!confirm('등록된 장소가 모두 초기화됩니다. 계속 진행할까요?')) return;
    } else if (warn.className.indexOf('warn-caution') >= 0) {
      if (!confirm('삭제되는 날짜의 일정이 제거됩니다. 계속 진행할까요?')) return;
    }
  }

  var btn = document.getElementById('btnEditSave');
  if (btn) { btn.disabled = true; btn.textContent = '저장 중…'; }

  fetch(CTX_PATH + '/trip/' + TRIP_ID, {
    method: 'PATCH',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      title:       title,
      tripName:    title,
      description: desc,
      startDate:   startD + 'T00:00:00',
      endDate:     endD   + 'T00:00:00',
      tripType:    type,
      isPublic:    isPublic,
      cities:      null
    })
  })
  .then(function (r) { return r.json(); })
  .then(function (d) {
    if (d.success) {
      closeModal('tripEditModal');
      location.reload();
    } else {
      alert('수정 실패: ' + (d.message || '오류가 발생했습니다.'));
      if (btn) { btn.disabled = false; btn.textContent = '저장하기'; }
    }
  })
  .catch(function (e) {
    alert('오류가 발생했습니다: ' + e.message);
    if (btn) { btn.disabled = false; btn.textContent = '저장하기'; }
  });
}

/* ══════════════════════════════
   DOMContentLoaded 이벤트 바인딩
══════════════════════════════ */
document.addEventListener('DOMContentLoaded', function () {
  // 설명 글자수 카운터
  var descEl = document.getElementById('editTripDesc');
  if (descEl) descEl.addEventListener('input', function () {
    var cnt = document.getElementById('editDescCount');
    if (cnt) cnt.textContent = this.value.length;
  });

  // 공개여부 토글 레이블
  var pubEl = document.getElementById('editIsPublic');
  if (pubEl) pubEl.addEventListener('change', function () {
    var lbl = document.getElementById('editPublicLabel');
    if (lbl) lbl.textContent = this.checked ? '공개 여행' : '비공개 여행';
  });

  // 날짜 변경 → 실시간 경고
  var sEl = document.getElementById('editStartDate');
  var eEl = document.getElementById('editEndDate');
  if (sEl) sEl.addEventListener('change', checkEditDateWarning);
  if (eEl) eEl.addEventListener('change', checkEditDateWarning);
});
