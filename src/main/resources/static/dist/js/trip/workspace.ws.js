/* ═══════════════════════════════════════════════════════════════
   workspace.ws.js  —  Tripan 워크스페이스 실시간 동기화
   ─────────────────────────────────────────────────────────────
   저장 구조:
     사용자 액션 → REST fetch() → DB 저장(영속)
     → wsPublisher.publish() → STOMP broadcast
     → 같은 방 다른 유저 DOM 갱신 (새로고침 없이)

   재진입 시:
     JSP 렌더 → TripController.workspace() → DB 최신 조회
     → 항상 최신 상태 (WebSocket 없어도 DB에 영구 저장됨)

   WebSocket 설정 (WebSocketConfig.java):
     endpoint  : /ws-tripan  (SockJS)
     broker    : /sub
     구독 주소 : /sub/trip/{tripId}

   수정:
     - copyInviteLink 제거 → workspace.ui.js 에서만 정의
     - wsAddPlace lat/lng 파라미터 추가 (지도 마커 연동)
═══════════════════════════════════════════════════════════════ */

var _stompClient = null;
var _wsConnected = false;
var _myNickname  = '';

/* ══════════════════════════════════════════════
   1. 연결 & 자동 재연결
══════════════════════════════════════════════ */
function wsConnect(tripId, ctxPath, myNick) {
  _myNickname = myNick || '';

  var socket = new SockJS(ctxPath + '/ws-tripan');
  _stompClient = Stomp.over(socket);
  _stompClient.debug = null;

  _stompClient.connect({}, function () {
    _wsConnected = true;
    wsSaveStatus('connected');

    _stompClient.subscribe('/sub/trip/' + tripId, function (frame) {
      try {
        var msg = JSON.parse(frame.body);
        wsHandle(msg);
      } catch (e) {
        console.warn('[WS] 파싱 오류', e);
      }
    });

    console.log('[WS] 연결됨 tripId=' + tripId);

  }, function () {
    _wsConnected = false;
    wsSaveStatus('disconnected');
    console.warn('[WS] 연결 끊김, 3초 후 재연결...');
    setTimeout(function () { wsConnect(tripId, ctxPath, myNick); }, 3000);
  });
}

/* ══════════════════════════════════════════════
   2. 메시지 핸들러
   내가 보낸 건 낙관적 업데이트로 이미 처리됨 → 무시
══════════════════════════════════════════════ */
function wsHandle(msg) {
  if (!msg || !msg.type) return;
  if (msg.senderNickname && msg.senderNickname === _myNickname) return;

  var p = msg.payload || {};

  switch (msg.type) {

    case 'ORDER_UPDATED':
      wsMoveCard(msg.targetId, p.dayNumber, p.visitOrder);
      wsToast(msg.senderNickname + '님이 일정 순서를 변경했어요 🔀');
      break;

    case 'PLACE_ADDED':
      wsAddPlace(p.dayNumber, msg.targetId, p.placeName, p.address || '', p.latitude || 0, p.longitude || 0);
      wsToast(msg.senderNickname + '님이 장소를 추가했어요 📍');
      break;

    case 'PLACE_DELETED':
      wsRemoveCard(msg.targetId);
      wsToast(msg.senderNickname + '님이 장소를 삭제했어요 🗑️');
      break;

    case 'MEMO_UPDATED':
      wsUpdateMemo(msg.targetId, p.memo);
      break;

    case 'CHECKLIST_ADDED':
      if (typeof loadChecklist === 'function') loadChecklist();
      wsToast(msg.senderNickname + '님이 체크리스트를 추가했어요 ✅');
      break;

    case 'CHECKLIST_TOGGLED':
      if (typeof loadChecklist === 'function') loadChecklist();
      break;

    case 'CHECKLIST_DELETED':
      var ci = document.querySelector('.check-item[data-id="' + msg.targetId + '"]');
      if (ci) ci.remove();
      break;

    case 'EXPENSE_ADDED':
    case 'EXPENSE_DELETED':
      if (typeof loadExpenseList === 'function') loadExpenseList();
      wsToast(msg.senderNickname + '님이 가계부를 수정했어요 💰');
      break;

    case 'VOTE_CREATED':
    case 'VOTE_CASTED':
    case 'VOTE_DELETED':
      if (typeof loadVotes === 'function') loadVotes();
      if (msg.type !== 'VOTE_CASTED')
        wsToast(msg.senderNickname + '님이 투표를 ' + (msg.type === 'VOTE_CREATED' ? '만들었어요 🗳️' : '삭제했어요 🗑️'));
      break;

    case 'TRIP_UPDATED':
      var titleEl = document.querySelector('.ws-topbar__title');
      if (titleEl && p.tripName) titleEl.textContent = p.tripName;
      wsToast(msg.senderNickname + '님이 여행 정보를 수정했어요 ✏️');
      break;

    case 'MEMBER_JOINED':
      wsToast('🎉 ' + (p.nickname || '새 멤버') + '님이 여행에 참여했어요!');
      break;
  }
}

/* ══════════════════════════════════════════════
   3. DOM 처리 함수들
══════════════════════════════════════════════ */

/**
 * 다른 유저가 장소 추가 시 내 화면에 카드 삽입
 * lat/lng 추가 → 지도 마커도 함께 찍음
 */
function wsAddPlace(dayNumber, itemId, placeName, address, lat, lng) {
  var list = document.getElementById('places-' + dayNumber);
  if (!list) return;
  if (list.querySelector('.place-card[data-id="' + itemId + '"]')) return; // 중복 방지

  var count = list.querySelectorAll('.place-card').length + 1;
  var card  = document.createElement('div');
  card.className = 'place-card';
  card.draggable = true;
  card.setAttribute('data-day',    dayNumber);
  card.setAttribute('data-id',     itemId);
  card.setAttribute('data-name',   placeName);
  card.setAttribute('data-memo',   '');
  card.setAttribute('data-imgurl', '');
  card.setAttribute('data-lat',    lat || 0);
  card.setAttribute('data-lng',    lng || 0);
  card.innerHTML =
    '<div class="place-num">' + count + '</div>' +
    '<div class="place-info">' +
      '<div class="place-name">' + _escapeHtml(placeName) + '</div>' +
      '<div class="place-addr">' + _escapeHtml(address)   + '</div>' +
      '<span class="place-type-badge">📍 장소</span>' +
      '<div class="place-chips"></div>' +
    '</div>' +
    '<div class="place-actions">' +
      '<button class="place-action-btn" onclick="openMemo(this)">📝</button>' +
      '<button class="place-action-btn" onclick="removePlace(this)">🗑</button>' +
    '</div>';

  if (typeof initDrag === 'function') initDrag(card);
  list.appendChild(card);
  if (typeof renumberPlaces === 'function') renumberPlaces(dayNumber);
  else if (typeof refreshPlaceNums === 'function') refreshPlaceNums(list);

  // 추가 강조
  card.style.outline      = '2px solid #89CFF0';
  card.style.borderRadius = '14px';
  card.style.animation    = 'fadeIn .3s ease';
  setTimeout(function () { card.style.outline = ''; card.style.borderRadius = ''; }, 1500);

  // 지도 마커
  if (typeof mapAddMarkerExternal === 'function' && lat && lng) {
    mapAddMarkerExternal(lat, lng, placeName, dayNumber, count);
  }
}

function _escapeHtml(str) {
  if (!str) return '';
  return str.replace(/&/g, '&amp;').replace(/</g, '&lt;')
            .replace(/>/g, '&gt;').replace(/"/g, '&quot;');
}

function wsMoveCard(itemId, dayNumber, visitOrder) {
  var card    = document.querySelector('.place-card[data-id="' + itemId + '"]');
  var newList = document.getElementById('places-' + dayNumber);
  if (!card || !newList) return;

  var siblings = Array.from(newList.querySelectorAll('.place-card'));
  var before   = null;
  for (var i = 0; i < siblings.length; i++) {
    if ((siblings[i].dataset.order || '999999') > visitOrder) { before = siblings[i]; break; }
  }

  card.dataset.day   = dayNumber;
  card.dataset.order = visitOrder;
  if (before) newList.insertBefore(card, before);
  else        newList.appendChild(card);

  if (typeof refreshPlaceNums === 'function') refreshPlaceNums(newList);

  card.style.outline      = '2px solid #89CFF0';
  card.style.borderRadius = '14px';
  setTimeout(function () { card.style.outline = ''; card.style.borderRadius = ''; }, 1200);
}

function wsRemoveCard(itemId) {
  var card = document.querySelector('.place-card[data-id="' + itemId + '"]');
  if (!card) return;
  var list = card.closest('.place-list');
  card.style.transition = 'opacity .25s, transform .25s';
  card.style.opacity    = '0';
  card.style.transform  = 'scale(.94)';
  setTimeout(function () {
    card.remove();
    if (list && typeof refreshPlaceNums === 'function') refreshPlaceNums(list);
  }, 260);
}

function wsUpdateMemo(itemId, memo) {
  var card = document.querySelector('.place-card[data-id="' + itemId + '"]');
  if (!card) return;
  var chip = card.querySelector('.memo-chip');
  if (memo && memo.trim()) {
    if (chip) { chip.textContent = memo; }
    else {
      var newChip = document.createElement('div');
      newChip.className   = 'memo-chip';
      newChip.textContent = memo;
      var info = card.querySelector('.place-info');
      if (info) info.appendChild(newChip);
    }
  } else if (chip) {
    chip.remove();
  }
}

/* ══════════════════════════════════════════════
   4. 저장 상태 표시
══════════════════════════════════════════════ */
var _saveTimer = null;

function wsSaveStatus(state) {
  var el = document.getElementById('wsSaveStatus');
  if (!el) return;
  var map = {
    saving:       '⏳ 저장 중...',
    saved:        '✅ 저장됨',
    error:        '⚠️ 저장 실패',
    connected:    '● 연결됨',
    disconnected: '○ 재연결 중...'
  };
  el.textContent   = map[state] || '';
  el.dataset.state = state;
  if (state === 'saved') {
    clearTimeout(_saveTimer);
    _saveTimer = setTimeout(function () { wsSaveStatus('connected'); }, 3000);
  }
}

/* ══════════════════════════════════════════════
   5. 동기화 토스트 (우상단 — showToast와 별개)
══════════════════════════════════════════════ */
var _wsToastTimer = null;

function wsToast(msg) {
  var el = document.getElementById('wsToast');
  if (!el) return;
  el.textContent = msg;
  el.classList.add('show');
  clearTimeout(_wsToastTimer);
  _wsToastTimer = setTimeout(function () { el.classList.remove('show'); }, 2800);
}

/* ══════════════════════════════════════════════
   6. 디바운싱 자동저장 유틸
══════════════════════════════════════════════ */
var _debounceMap = {};

function debounceSave(key, delayMs, saveFn) {
  wsSaveStatus('saving');
  clearTimeout(_debounceMap[key]);
  _debounceMap[key] = setTimeout(function () {
    saveFn()
      .then(function (r) { wsSaveStatus(r.ok ? 'saved' : 'error'); })
      .catch(function ()  { wsSaveStatus('error'); });
  }, delayMs);
}

/* ══════════════════════════════════════════════
   7. 낙관적 업데이트 체크리스트 toggle
══════════════════════════════════════════════ */
function toggleCheckOptimistic(checklistId, labelEl, cbEl) {
  var nowDone = !labelEl.classList.contains('checked');
  labelEl.classList.toggle('checked', nowDone);
  if (cbEl) cbEl.checked = nowDone;

  fetch(CTX_PATH + '/api/trip/' + TRIP_ID + '/checklist/' + checklistId + '/toggle', {
    method: 'PATCH'
  })
  .then(function (r) {
    if (!r.ok) throw new Error('toggle fail');
    wsSaveStatus('saved');
  })
  .catch(function () {
    labelEl.classList.toggle('checked', !nowDone);
    if (cbEl) cbEl.checked = !nowDone;
    if (typeof showToast === 'function') showToast('⚠️ 저장에 실패했어요. 다시 시도해주세요.');
  });
}
