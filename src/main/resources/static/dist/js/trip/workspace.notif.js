/**
 * workspace.notif.js
 * ──────────────────────────────────────────────
 * 담당: 알림 드롭다운 · 목록 로드 · 읽음 처리 · 초대 수락/거절
 * ──────────────────────────────────────────────
 */

var _notifOpen = false;

/* ══════════════════════════════
   드롭다운 토글
══════════════════════════════ */
function toggleNotif() {
  _notifOpen = !_notifOpen;
  document.getElementById('notifDropdown').classList.toggle('active', _notifOpen);
  document.getElementById('notifDim').classList.toggle('active', _notifOpen);
  if (_notifOpen) loadNotifList();
}

function closeNotif() {
  _notifOpen = false;
  document.getElementById('notifDropdown').classList.remove('active');
  document.getElementById('notifDim').classList.remove('active');
}
/* ══════════════════════════════
   알림 목록 로드 & 렌더
   ← JSP 인라인에서 이동
══════════════════════════════ */
function loadNotifList() {
  fetch(CTX_PATH + '/api/notification?tripId=' + TRIP_ID)
    .then(function (r) { return r.ok ? r.json() : Promise.reject(r.status); })
    .then(function (list) {
      list = (list || []).map(normalizeRow);

      var typeIcon  = { INVITE:'✉️', ACCEPT:'✅', SYSTEM:'🔔', VOTE:'🗳️', COMMENT:'💬' };
      var unreadCnt = list.filter(function (n) { return n.isRead === 0; }).length;

      var dot = document.getElementById('notifDot');
      if (dot) dot.style.display = unreadCnt > 0 ? 'block' : 'none';

      var html = list.length === 0
        ? '<div style="text-align:center;padding:32px 20px;color:#A0AEC0;">' +
          '<div style="font-size:32px;margin-bottom:8px;">🔔</div>' +
          '<div style="font-size:13px;">새 알림이 없어요</div></div>'
        : list.map(function (n) {
            var icon   = typeIcon[n.type] || '🔔';
            var unread = n.isRead === 0 ? ' unread' : '';
            var dot2   = n.isRead === 0 ? '<div class="notif-item-unread-dot"></div>' : '';
            return '<div class="notif-item' + unread + '" onclick="markNotifRead(' + n.notificationId + ',this)">'
              + '<div class="notif-item-icon">' + icon + '</div>'
              + '<div class="notif-item-info">'
              + '<div class="notif-item-text">' + n.message + '</div>'
              + '<div class="notif-item-time">' + n.timeAgo + '</div>'
              + '</div>' + dot2 + '</div>';
          }).join('');

      var listEl = document.getElementById('notifList');
      if (listEl) listEl.innerHTML = html;
    })
    .catch(function () {
      var listEl = document.getElementById('notifList');
      if (listEl) listEl.innerHTML =
        '<div style="text-align:center;padding:16px;color:#bbb;font-size:13px">알림을 불러오지 못했어요</div>';
    });
}

/* ══════════════════════════════
   개별 읽음
   ← JSP 인라인에서 이동
══════════════════════════════ */
function markNotifRead(notifId, el) {
  if (el) el.classList.remove('unread');
  var dot = el ? el.querySelector('.notif-item-unread-dot') : null;
  if (dot) dot.remove();
  fetch(CTX_PATH + '/api/notification/' + notifId + '/read', { method: 'PATCH' });
  var remaining = document.querySelectorAll('.notif-item.unread').length;
  var badge = document.getElementById('notifDot');
  if (badge) badge.style.display = remaining > 0 ? 'block' : 'none';
}

/* ══════════════════════════════
   전체 읽음
══════════════════════════════ */
function clearAllNotif() {
  fetch(CTX_PATH + '/api/notification/read-all?tripId=' + TRIP_ID, { method: 'PATCH' })
    .then(function () {
      loadNotifList();
      showToast('🔔 모두 읽음 처리됐어요');
    });
}

/* ══════════════════════════════
   초대 수락
══════════════════════════════ */
function acceptInvite(itemId, tripId, memberId) {
  var actions = document.getElementById(itemId + '-actions');
  if (actions) actions.innerHTML = '<span style="font-size:12px;color:#A0AEC0;">처리 중...</span>';

  fetch(CTX_PATH + '/trip/' + (tripId || TRIP_ID) + '/member/' + memberId + '/accept', {
    method: 'PATCH'
  })
  .then(function (r) { return r.json(); })
  .then(function (d) {
    if (d.success) {
      if (actions) actions.innerHTML = '<span style="font-size:12px;font-weight:700;color:#276749;">✓ 수락 완료</span>';
      var item = document.getElementById(itemId);
      if (item) item.classList.remove('unread');
      showToast('✅ 초대를 수락했어요!');
      closeNotif();
    } else {
      if (actions) actions.innerHTML = '<span style="color:#E53E3E;font-size:12px;">수락 실패</span>';
      showToast('⚠️ 수락에 실패했어요');
    }
  })
  .catch(function () {
    if (actions) actions.innerHTML = '<span style="color:#E53E3E;font-size:12px;">오류 발생</span>';
    showToast('⚠️ 서버 오류');
  });
}

/* ══════════════════════════════
   초대 거절
══════════════════════════════ */
function declineInvite(itemId, tripId, memberId) {
  fetch(CTX_PATH + '/trip/' + (tripId || TRIP_ID) + '/member/' + memberId + '/decline', {
    method: 'DELETE'
  })
  .then(function (r) { return r.json(); })
  .then(function (d) {
    if (d.success) {
      var item = document.getElementById(itemId);
      if (item) {
        item.style.transition = 'opacity .3s';
        item.style.opacity    = '0';
        setTimeout(function () { item.remove(); }, 300);
      }
      showToast('🚫 초대를 거절했어요');
      closeNotif();
    } else {
      showToast('⚠️ 거절에 실패했어요');
    }
  })
  .catch(function () { showToast('⚠️ 서버 오류'); });
}

/* ══════════════════════════════
   자동 초기 로드
══════════════════════════════ */
document.addEventListener('DOMContentLoaded', function () {
  loadNotifList();
});
