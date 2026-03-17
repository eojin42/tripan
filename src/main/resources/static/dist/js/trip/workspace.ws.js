/* ═══════════════════════════════════════════════════════════════
   workspace.ws.js  —  Tripan 워크스페이스 실시간 동기화

   수정 내역:
    [1] MEMO_UPDATED 핸들러 개선
        - 기존: wsUpdateMemo(itemId, memo) → 메모 텍스트만 DOM에 직접 써넣음
                → 동행자 화면에 갑자기 메모 내용이 raw 텍스트로 나타남
        - 변경: wsUpdateMemoFull(itemId, memo, imageUrls) 호출
                → schedule.js의 함수를 통해 뱃지 방식으로 업데이트
                → 뱃지 클릭 시 조회 모달로 내용 확인 가능

    [2] wsAddPlace에 chip 이벤트 바인딩 추가
        - 새 카드 삽입 후 _bindChipClick(card) 호출
        - data-images 속성 초기화

    [3] wsUpdateMemo(구버전) 유지 — 하위 호환용
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
// ── ORDER_UPDATED 배치 큐 ────────────────────────────────
// 짧은 시간(100ms) 내 동일 day의 메시지를 모아서 DOM을 한 번에 재정렬
// 이렇게 하면 N개 메시지가 연속으로 와도 중간 상태 없이 최종 순서만 반영됨
var _wsOrderQueue   = {}; // { dayNumber: { itemId: visitOrder } }
var _wsOrderTimers  = {}; // { dayNumber: timerHandle }
var _wsOrderSender  = {}; // { dayNumber: nickname }

function _wsEnqueueOrder(itemId, dayNumber, visitOrder, senderNick) {
  var day = String(dayNumber);
  if (!_wsOrderQueue[day]) _wsOrderQueue[day] = {};
  _wsOrderQueue[day][String(itemId)] = visitOrder;
  _wsOrderSender[day] = senderNick;

  clearTimeout(_wsOrderTimers[day]);
  _wsOrderTimers[day] = setTimeout(function() {
    _wsFlushOrders(day);
  }, 80); // 80ms 내 같은 day 메시지 모두 수집 후 처리
}

function _wsFlushOrders(day) {
  var orderMap = _wsOrderQueue[day];
  var nick     = _wsOrderSender[day];
  _wsOrderQueue[day]  = {};
  _wsOrderTimers[day] = null;

  if (!orderMap || !Object.keys(orderMap).length) return;

  var list = document.getElementById('places-' + day);
  if (!list) return;

  // 현재 DOM 순서를 기반으로 카드를 가져오되, visitOrder 업데이트
  var cards = Array.from(list.querySelectorAll('.place-card'));

  // orderMap에 있는 카드의 visitOrder 업데이트
  cards.forEach(function(card) {
    var newOrder = orderMap[String(card.dataset.id)];
    if (newOrder !== undefined) {
      card.dataset.order = newOrder;
      // day 변경도 반영
      card.dataset.day = day;
    }
  });

  // visitOrder 숫자값 기준으로 정렬해서 DOM 재배치
  cards.sort(function(a, b) {
    return parseInt(a.dataset.order || '999999', 10) - parseInt(b.dataset.order || '999999', 10);
  });
  cards.forEach(function(card) { list.appendChild(card); });

  if (typeof refreshPlaceNums === 'function') refreshPlaceNums(list);
  if (typeof notifySummaryChanged === 'function') setTimeout(notifySummaryChanged, 100);
  if (typeof _reorderMarkersForDay === 'function') _reorderMarkersForDay(parseInt(day));
  wsToast((nick || '상대방') + '님이 일정 순서를 변경했어요 🔀');
}
// ─────────────────────────────────────────────────────────

function wsHandle(msg) {
  if (!msg || !msg.type) return;
  if (msg.senderNickname && msg.senderNickname === _myNickname) return;

  var p = msg.payload || {};

  switch (msg.type) {

    case 'ORDER_UPDATED':
      // 짧은 시간 내 같은 day의 ORDER_UPDATED를 모아서 한 번에 정렬 (배치 처리)
      _wsEnqueueOrder(msg.targetId, p.dayNumber, p.visitOrder, msg.senderNickname);
      break;

    case 'LIST_REORDERED':
      // ★ 핵심: 개별 N번 wsMoveCard 대신 전체 순서를 한 번에 DOM 재정렬
      // p.items = [{itemId, visitOrder}, ...], p.dayNumber
      wsReorderList(p.dayNumber, p.items || []);
      // 조용히 처리 (순서 변경 토스트는 발송자만 봄)
      break;

    case 'PLACE_ADDED':
      //  카테고리 파라미터(p.categoryName) 추가 전달
      wsAddPlace(p.dayNumber, msg.targetId, p.placeName,
                 p.address || '', p.latitude || 0, p.longitude || 0, p.categoryName);
      wsToast(msg.senderNickname + '님이 장소를 추가했어요 📍');
      break;

    case 'PLACE_DELETED':
      wsRemoveCard(msg.targetId);
      // 누군가 장소를 지웠을 때 지도 마커도 실시간으로 뽑아버림
      if (typeof mapRemoveMarker === 'function') {
          mapRemoveMarker(msg.targetId);
      }
      wsToast(msg.senderNickname + '님이 장소를 삭제했어요 🗑️');
      break;

    case 'MEMO_UPDATED':
      var imageUrls = p.imageUrls || (p.imageUrl ? [p.imageUrl] : []);
      if (typeof wsUpdateMemoFull === 'function') {
        wsUpdateMemoFull(msg.targetId, p.memo, imageUrls);
      } else {
        wsUpdateMemo(msg.targetId, p.memo);
      }
      wsToast(msg.senderNickname + '님이 메모를 수정했어요 📝');
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
        wsToast(msg.senderNickname + '님이 투표를 ' +
                (msg.type === 'VOTE_CREATED' ? '만들었어요 🗳️' : '삭제했어요 🗑️'));
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
function wsAddPlace(dayNumber, itemId, placeName, address, lat, lng, categoryName) {
  var list = document.getElementById('places-' + dayNumber);
  if (!list) return;
  if (list.querySelector('.place-card[data-id="' + itemId + '"]')) return; // 중복 방지

  var count = list.querySelectorAll('.place-card').length + 1;
  
  var catInfo = (typeof window.getTripanCategory === 'function') 
                ? window.getTripanCategory(categoryName) 
                : { icon: '📍', label: categoryName || '장소' };

  var card  = document.createElement('div');
  card.className = 'place-card';
  card.draggable = true;
  card.setAttribute('data-day',    dayNumber);
  card.setAttribute('data-id',     itemId);
  card.setAttribute('data-name',   placeName);
  card.setAttribute('data-memo',   '');
  card.setAttribute('data-imgurl', '');
  card.setAttribute('data-images', '[]');
  card.setAttribute('data-lat',    lat || 0);
  card.setAttribute('data-lng',    lng || 0);

  card.innerHTML =
    '<div class="place-num">' + count + '</div>' +
    '<div class="place-info">' +
      '<div class="place-name">' + _escapeHtml(placeName) + '</div>' +
      '<div class="place-addr">' + _escapeHtml(address)   + '</div>' +
      '<span class="place-type-badge">' + catInfo.icon + ' ' + catInfo.label + '</span>' + 
      '<div class="place-chips"></div>' +
    '</div>' +
    '<div class="place-actions">' +
      '<button class="place-action-btn" onclick="openMemo(this)">📝</button>' +
      '<button class="place-action-btn" onclick="removePlace(this)">🗑</button>' +
    '</div>';

  if (typeof initDrag      === 'function') initDrag(card);
  if (typeof _bindChipClick === 'function') _bindChipClick(card);

  list.appendChild(card);
  if (typeof renumberPlaces   === 'function') renumberPlaces(dayNumber);
  else if (typeof refreshPlaceNums === 'function') refreshPlaceNums(list);

  card.style.outline      = '2px solid #89CFF0';
  card.style.borderRadius = '14px';
  card.style.animation    = 'fadeIn .3s ease';
  setTimeout(function () { card.style.outline = ''; card.style.borderRadius = ''; }, 1500);

  if (typeof notifySummaryChanged === 'function') setTimeout(notifySummaryChanged, 200);

  if (typeof mapAddMarkerExternal === 'function' && lat && lng) {
    var catForMap = categoryName || '장소';
    mapAddMarkerExternal(lat, lng, placeName, dayNumber, count, itemId, catForMap, address);
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

  // ✅ 숫자 비교 (문자열 'p','U' 등 LexoRank값 vs '000001' 혼용 버그 방지)
  var targetNum = parseInt(visitOrder, 10) || 0;
  var siblings  = Array.from(newList.querySelectorAll('.place-card'));
  var before    = null;
  for (var i = 0; i < siblings.length; i++) {
    if (parseInt(siblings[i].dataset.order || '999999', 10) > targetNum) { before = siblings[i]; break; }
  }

  card.dataset.day   = dayNumber;
  card.dataset.order = visitOrder;
  if (before) newList.insertBefore(card, before);
  else        newList.appendChild(card);

  if (typeof refreshPlaceNums === 'function') refreshPlaceNums(newList);
  if (typeof notifySummaryChanged === 'function') setTimeout(notifySummaryChanged, 100);

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
    if (typeof notifySummaryChanged === 'function') notifySummaryChanged();
  }, 260);
}

/**
 * wsReorderList — LIST_REORDERED 수신 시 해당 DAY 전체를 items 순서대로 DOM 재정렬
 * items 순서 = 최종 확정 순서 → 중간 상태 없이 한 번에 적용
 */
function wsReorderList(dayNumber, items) {
  var list = document.getElementById('places-' + dayNumber);
  if (!list || !items || !items.length) return;

  // ✅ 전체 DOM에서 카드 찾기 (다른 DAY에서 이동해 온 카드도 포함)
  var cardMap = {};
  document.querySelectorAll('.place-card').forEach(function(card) {
    if (card.dataset.id) cardMap[card.dataset.id] = card;
  });

  // items 순서대로 list에 재삽입 (없으면 다른 DAY에서 이동)
  items.forEach(function(item) {
    var card = cardMap[String(item.itemId)];
    if (!card) return;
    card.dataset.order = item.visitOrder;
    card.dataset.day   = String(dayNumber);
    list.appendChild(card);
  });

  // items에 포함되지 않은 카드가 이 list에 남아있으면 제거 (다른 day로 이동된 것)
  Array.from(list.querySelectorAll('.place-card')).forEach(function(card) {
    var inItems = items.some(function(it) { return String(it.itemId) === card.dataset.id; });
    if (!inItems) {
      // 이 카드는 다른 day로 이동됐으므로 list에서 꺼냄 (해당 day LIST_REORDERED가 처리)
      list.removeChild(card);
    }
  });

  if (typeof refreshPlaceNums === 'function') refreshPlaceNums(list);
  if (typeof notifySummaryChanged === 'function') setTimeout(notifySummaryChanged, 100);
  if (typeof _reorderMarkersForDay === 'function') _reorderMarkersForDay(dayNumber);
}

/**
 * [3] wsUpdateMemo — 구버전 하위 호환 (schedule.js v1 사용 시)
 * schedule.js v2 사용 시엔 wsUpdateMemoFull이 대신 호출됨
 */
function wsUpdateMemo(itemId, memo) {
  var card = document.querySelector('.place-card[data-id="' + itemId + '"]');
  if (!card) return;

  // 구버전 memo-chip 방식 제거 후 뱃지 방식으로 교체
  var oldChip = card.querySelector('.memo-chip');
  if (oldChip) oldChip.remove();

  // schedule.js v2 함수가 있으면 위임
  if (typeof wsUpdateMemoFull === 'function') {
    wsUpdateMemoFull(itemId, memo, []);
    return;
  }

  // 구버전 fallback: place-chips에 뱃지 추가
  var chips    = card.querySelector('.place-chips');
  if (!chips) return;
  var memoChip = chips.querySelector('.place-chip.memo');
  if (memo && memo.trim()) {
    card.dataset.memo = memo;
    if (!memoChip) chips.insertAdjacentHTML('beforeend', '<span class="place-chip memo">📝 메모</span>');
  } else {
    card.dataset.memo = '';
    if (memoChip) memoChip.remove();
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
   5. 동기화 토스트 (우상단)
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
