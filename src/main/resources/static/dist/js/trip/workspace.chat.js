/**
 * workspace.chat.js v20260322 — 여행 워크스페이스 채팅
 * ─────────────────────────────────────────────
 * 의존: CTX_PATH, TRIP_ID, MY_MEMBER_ID, MY_NICK (workspace.jsp에서 주입)
 *       SockJS + STOMP (이미 로드됨)
 * ─────────────────────────────────────────────
 */
console.log('[Chat] workspace.chat.js v20260322 로드됨');

/* ══════════════════════════════════════════
   상태
══════════════════════════════════════════ */
var _chat = {
  roomId:            null,
  open:              false,
  loadingMore:       false,
  oldestMsgId:       null,
  stompSub:          null,
  unread:            0,
  localLastReadMsgId: null  // 서버 XML 무관하게 로컬에서 관리하는 마지막 읽은 msgId
};

// CSS .chat-mem-avatar--0~5 와 완전 동일한 팔레트
var _AVATAR_COLORS = ['#D99ABC', '#E8B8D8', '#77ACF2', '#E8C66A', '#F2BC79', '#85C9B8'];
function _avatarColor(memberId) {
  var id = parseInt(memberId, 10) || 0;
  return _AVATAR_COLORS[id % _AVATAR_COLORS.length];
}

/* ══════════════════════════════════════════
   초기화 (DOMContentLoaded 후 호출)
══════════════════════════════════════════ */
function initChat() {
  fetch(CTX_PATH + '/api/trips/' + TRIP_ID + '/chat/room')
    .then(function(r) { return r.ok ? r.json() : null; })
    .then(function(data) {
      if (!data) return;
      _chat.roomId = data.chatRoomId;
      _setUnread(data.unreadCount || 0);

      // 서버에서 받은 lastReadMessageId를 로컬 기준으로 저장
      if (data.lastReadMessageId) {
        _chat.localLastReadMsgId = data.lastReadMessageId;
      }

      _subscribeChat();
    })
    .catch(function(e) { console.warn('[Chat] 초기화 실패', e); });
}

/* 아바타 색상 주입 — WS 연결과 무관하게 DOM 준비 즉시 실행 */
function _initAvatarColors() {
  document.querySelectorAll('.chat-mem-avatar[data-member-id]').forEach(function(el) {
    var mid = el.getAttribute('data-member-id');
    var c   = _avatarColor(mid);
    el.style.background = c;
    if (el.classList.contains('chat-mem-avatar--me')) {
      el.style.boxShadow = '0 0 0 2px #fff, 0 0 0 3.5px ' + c;
    }
  });
}

/* ── WebSocket 구독 ── */
function _subscribeChat() {
  if (!window._stompClient || !_wsConnected) {
    setTimeout(_subscribeChat, 800);
    return;
  }
  if (_chat.stompSub) return;

  _chat.stompSub = _stompClient.subscribe(
    '/sub/trip/' + TRIP_ID + '/chat',
    function(frame) {
      try {
        var msg = JSON.parse(frame.body);
        if (msg.type === 'NEW_MESSAGE' && msg.message) {
          _onNewMessage(msg.message);
        }
      } catch(e) { console.warn('[Chat] WS 파싱 오류', e); }
    }
  );

  // ★ WS 재연결 시 서버에서 unread 재조회 (재연결 후 놓친 메시지 배지 복구)
  if (_chat.roomId) {
    fetch(CTX_PATH + '/api/trips/' + TRIP_ID + '/chat/unread')
      .then(function(r) { return r.ok ? r.json() : null; })
      .then(function(d) { if (d && !_chat.open) _setUnread(d.unreadCount || 0); })
      .catch(function() {});
  }
}

/* ══════════════════════════════════════════
   채팅창 열기 / 닫기
══════════════════════════════════════════ */
function toggleChat() {
  if (_chat.open) {
    _closeChat();
  } else {
    _openChat();
  }
}

function _openChat() {
  var modal = document.getElementById('chatModal');
  if (!modal) return;
  if (_chat.open) return;
  _chat.open = true;

  // 로컬에 저장된 unread 수와 마지막 읽은 msgId 사용
  var localUnread   = _chat.unread;
  var localLastRead = _chat.localLastReadMsgId;

  _setUnread(0);
  modal.classList.add('open');
  _chat.oldestMsgId = null;

  // roomId가 없으면 먼저 조회
  if (!_chat.roomId) {
    fetch(CTX_PATH + '/api/trips/' + TRIP_ID + '/chat/room')
      .then(function(r) { return r.ok ? r.json() : null; })
      .then(function(data) {
        if (data && data.chatRoomId) _chat.roomId = data.chatRoomId;
        console.log('[Chat] _openChat localUnread=', localUnread, 'localLastRead=', localLastRead);
        _doLoadAndScroll(localUnread, localLastRead);
      })
      .catch(function() { _doLoadAndScroll(0, null); });
  } else {
    console.log('[Chat] _openChat localUnread=', localUnread, 'localLastRead=', localLastRead);
    _doLoadAndScroll(localUnread, localLastRead);
  }
}

function _doLoadAndScroll(unread, lastReadId) {
  var list = document.getElementById('chatMessageList');
  if (list) list.innerHTML = '<div class="chat-loading-text">불러오는 중...</div>';

  if (!_chat.roomId) return;

  fetch(CTX_PATH + '/api/trips/' + TRIP_ID + '/chat/messages?limit=50')
    .then(function(r) { return r.ok ? r.json() : []; })
    .then(function(msgs) {
      _chat.loadingMore = false;
      if (!_chat.open) return; // 로드 중 닫혔으면 중단

      var list = document.getElementById('chatMessageList');
      if (!list) return;

      console.log('[Chat] 메시지 수=', msgs.length, '/ unread=', unread, '/ lastReadId=', lastReadId);

      if (!msgs.length) {
        list.innerHTML = '<div class="chat-empty-text">아직 채팅 내역이 없습니다.<br>첫 번째 메시지를 보내보세요! 💬</div>';
        _markRead();
        return;
      }

      if (msgs[0]) _chat.oldestMsgId = msgs[0].messageId;
      list.innerHTML = msgs.map(_buildMsgHtml).join('');

      var dividerInserted = false;
      if (unread > 0 && lastReadId) {
        dividerInserted = _insertUnreadDivider(list, lastReadId, unread);
      }

      requestAnimationFrame(function() {
        requestAnimationFrame(function() {
          if (!_chat.open) return;
          var list = document.getElementById('chatMessageList');
          if (!list) return;

          if (dividerInserted) {
            var divider = list.querySelector('.chat-unread-divider');
            if (divider) {
              // getBoundingClientRect: 현재 뷰포트 기준 위치
              // list.scrollTop + (divider위치 - list위치) = divider의 list 내 절대 위치
              var listTop    = list.getBoundingClientRect().top;
              var divTop     = divider.getBoundingClientRect().top;
              var currentScrollTop = list.scrollTop;
              list.scrollTop = currentScrollTop + (divTop - listTop) - 8;
              console.log('[Chat] 구분선 스크롤 listTop=', listTop, 'divTop=', divTop, '→ scrollTop=', list.scrollTop);
            } else {
              list.scrollTop = list.scrollHeight;
            }
          } else {
            list.scrollTop = list.scrollHeight;
          }
          console.log('[Chat] scrollTop after=', list.scrollTop, '/ scrollHeight=', list.scrollHeight);

          // 현재 렌더된 마지막 메시지 ID를 로컬에 저장
          var allMsgs = list.querySelectorAll('.chat-msg[data-msg-id]');
          var lastMsg = allMsgs[allMsgs.length - 1];
          if (lastMsg) {
            _chat.localLastReadMsgId = parseInt(lastMsg.getAttribute('data-msg-id'), 10);
          }

          _markRead();
        });
      });
    })
    .catch(function() {
      if (!_chat.open) return;
      var list = document.getElementById('chatMessageList');
      if (list) list.innerHTML = '<div class="chat-empty-text">메시지를 불러오지 못했습니다.</div>';
    });
}

function _closeChat() {
  var modal = document.getElementById('chatModal');
  if (!modal) return;
  _chat.open = false;
  modal.classList.remove('open');
  // markRead는 여기서 호출 안 함 — 스크롤 완료(메시지 실제로 봤을 때)에만 호출
}

/* ══════════════════════════════════════════
   메시지 로드 (무한스크롤 전용 — 위로 스크롤 시 이전 메시지 추가)
══════════════════════════════════════════ */
function _loadMessages(beforeId, scrollToBottom, unreadCount, lastReadMsgId, onComplete) {
  if (!_chat.roomId || !beforeId) return; // 무한스크롤은 beforeId 필수
  if (_chat.loadingMore) return;
  _chat.loadingMore = true;

  var list = document.getElementById('chatMessageList');
  var prevHeight = list ? list.scrollHeight : 0;

  fetch(CTX_PATH + '/api/trips/' + TRIP_ID + '/chat/messages?limit=50&beforeId=' + beforeId)
    .then(function(r) { return r.ok ? r.json() : []; })
    .then(function(msgs) {
      _chat.loadingMore = false;
      if (!list || !msgs.length) return;

      if (msgs[0]) _chat.oldestMsgId = msgs[0].messageId;

      list.insertAdjacentHTML('afterbegin', msgs.map(_buildMsgHtml).join(''));
      // 스크롤 위치 유지 (위에 내용이 추가됐으므로 높이 차이만큼 보정)
      list.scrollTop = list.scrollHeight - prevHeight;
    })
    .catch(function() { _chat.loadingMore = false; });
}

/**
 * lastReadMsgId 바로 다음 메시지 앞에 구분선 삽입
 * @returns {boolean} 삽입 성공 여부
 */
function _insertUnreadDivider(list, lastReadMsgId, unreadCount) {
  var allMsgs  = list.querySelectorAll('.chat-msg[data-msg-id]');
  var inserted = false;
  var threshold = parseInt(lastReadMsgId, 10);

  for (var i = 0; i < allMsgs.length; i++) {
    var msgId = parseInt(allMsgs[i].getAttribute('data-msg-id'), 10);
    if (!isNaN(msgId) && msgId > threshold) {
      var dividerHtml = '<div class="chat-unread-divider">'
        + '<span class="chat-unread-divider__line"></span>'
        + '<span class="chat-unread-divider__label">읽지 않은 메시지 ' + unreadCount + '개</span>'
        + '<span class="chat-unread-divider__line"></span>'
        + '</div>';
      allMsgs[i].insertAdjacentHTML('beforebegin', dividerHtml);
      inserted = true;
      break;
    }
  }

  // 50개 범위 안에 lastReadMsgId가 없는 경우 → 맨 위에 배너
  if (!inserted && allMsgs.length > 0) {
    var topDividerHtml = '<div class="chat-unread-divider chat-unread-divider--top">'
      + '<span class="chat-unread-divider__label">📩 읽지 않은 메시지 ' + unreadCount + '개</span>'
      + '</div>';
    list.insertAdjacentHTML('afterbegin', topDividerHtml);
    inserted = true;
  }

  return inserted;
}

/* ══════════════════════════════════════════
   메시지 전송
══════════════════════════════════════════ */
function sendChatMessage() {
  var input = document.getElementById('chatInput');
  if (!input) return;
  var content = input.value.trim();
  if (!content) return;

  // IME 잔재 방어: 줄바꿈 보존, 연속 3개 이상만 2개로 축소
  content = content.replace(/\n{3,}/g, '\n\n').trim();
  if (!content) return;

  var sendBtn = document.getElementById('chatSendBtn');
  if (sendBtn) { sendBtn.disabled = true; }
  input.value = '';
  input.style.height = 'auto';

  fetch(CTX_PATH + '/api/trips/' + TRIP_ID + '/chat/messages', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ content: content, messageType: 'TALK' })
  })
  .then(function(r) { return r.ok ? r.json() : null; })
  .then(function(data) {
    if (sendBtn) sendBtn.disabled = false;
    // WS broadcast로 수신되므로 여기서는 추가 처리 불필요
    // (내 메시지도 WS로 수신됨 → mine=false로 와서 직접 추가)
    if (data && data.message) {
      _appendMessage(data.message, true);
    }
  })
  .catch(function() {
    if (sendBtn) sendBtn.disabled = false;
    showToast('⚠️ 메시지 전송 실패');
  });
}

/* ══════════════════════════════════════════
   실시간 메시지 수신
══════════════════════════════════════════ */
function _onNewMessage(msg) {
  var isMe = String(msg.memberId) === String(MY_MEMBER_ID);

  if (_chat.open) {
    if (!isMe) {
      _appendMessage(msg, false);
    }
    _markRead();
  } else {
    if (!isMe) {
      // 읽지 않은 새 메시지: localLastReadMsgId는 현재 마지막 읽은 ID 유지
      // 아직 localLastReadMsgId가 없으면 이 메시지 직전 ID를 기록할 수 없으므로
      // _chat.unread만 증가
      _setUnread(_chat.unread + 1);
    }
  }
}

function _appendMessage(msg, isMe) {
  var list = document.getElementById('chatMessageList');
  if (!list) return;

  // 빈상태 문구 있으면 제거
  var emptyEl = list.querySelector('.chat-empty-text, .chat-loading-text');
  if (emptyEl) emptyEl.remove();

  // ★ isMe 파라미터 무시 — memberId 기준으로만 판별 (mine 필드 오염 방지)
  list.insertAdjacentHTML('beforeend', _buildMsgHtml(msg));

  // 스크롤 하단 고정
  list.scrollTop = list.scrollHeight;
}

/* ══════════════════════════════════════════
   HTML 빌더
══════════════════════════════════════════ */
function _buildMsgHtml(msg) {
  if (msg.messageType === 'SYSTEM' || msg.messageType === 'JOIN' || msg.messageType === 'LEAVE') {
    return '<div class="chat-msg--system"><span>' + _escChat(msg.content) + '</span></div>';
  }

  // ★ msg.mine 필드는 무시 — WS broadcast에서 mine=true가 수신자에게도 오는 오염 방지
  // memberId 기준으로만 판별
  var mine   = String(msg.memberId) === String(MY_MEMBER_ID);
  var side   = mine ? 'chat-msg--me' : 'chat-msg--other';
  var time   = msg.createdAt ? msg.createdAt.substring(11, 16) : '';
  var color  = _avatarColor(msg.memberId);

  var avatarHtml = '';
  if (!mine) {
    var initial = (msg.nickname || '?').substring(0, 2);
    if (msg.profileImage) {
      avatarHtml = '<img class="chat-avatar" src="' + _escChat(msg.profileImage) + '" alt="' + _escChat(initial) + '" onerror="this.style.display=\'none\';this.nextSibling.style.display=\'flex\'">'
                 + '<div class="chat-avatar chat-avatar--initial" style="display:none;background:' + color + '">' + _escChat(initial) + '</div>';
    } else {
      avatarHtml = '<div class="chat-avatar chat-avatar--initial" style="background:' + color + '">' + _escChat(initial) + '</div>';
    }
  }

  var nameHtml = !mine
    ? '<div class="chat-msg__name">' + _escChat(msg.nickname || '알 수 없음') + '</div>'
    : '';

  // 내 말풍선: memberId 기반 고유 색으로 (그라데이션 아닌 단색)
  var bubbleStyle = mine
    ? ' style="background:' + color + ';color:#fff;white-space:pre-wrap"'
    : ' style="white-space:pre-wrap"';

  return '<div class="chat-msg ' + side + '" data-msg-id="' + (msg.messageId || '') + '">'
       + (avatarHtml ? '<div class="chat-msg__avatar">' + avatarHtml + '</div>' : '')
       + '<div class="chat-msg__body">'
       +   nameHtml
       +   '<div class="chat-msg__bubble"' + bubbleStyle + '>' + _escChat(msg.content) + '</div>'
       +   '<div class="chat-msg__time">' + time + '</div>'
       + '</div>'
       + '</div>';
}

function _escChat(str) {
  if (!str) return '';
  return String(str)
    .replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;')
    .replace(/"/g,'&quot;')
    .replace(/\n/g,'<br>');
}

/* ══════════════════════════════════════════
   읽음 처리 / 배지
══════════════════════════════════════════ */
function _markRead() {
  if (!_chat.roomId) return;
  fetch(CTX_PATH + '/api/trips/' + TRIP_ID + '/chat/read', { method: 'PATCH' })
    .catch(function() {});
}

function _setUnread(count) {
  _chat.unread = count;
  var badge = document.getElementById('chatUnreadBadge');
  if (!badge) return;
  if (count > 0) {
    badge.textContent = count > 99 ? '99+' : count;
    badge.style.display = 'flex';
  } else {
    badge.style.display = 'none';
  }
}

/* ══════════════════════════════════════════
   무한 스크롤 (위로 스크롤 시 이전 메시지 로드)
══════════════════════════════════════════ */
function _onChatScroll(el) {
  if (el.scrollTop < 60 && !_chat.loadingMore && _chat.oldestMsgId) {
    _loadMessages(_chat.oldestMsgId, false, 0, null, null);
  }
}

/* ══════════════════════════════════════════
   입력창 자동 높이 조절
══════════════════════════════════════════ */
function onChatInputChange(el) {
  el.style.height = 'auto';
  el.style.height = Math.min(el.scrollHeight, 100) + 'px';
}

/* Enter 전송 (Shift+Enter = 줄바꿈) */
function onChatInputKeydown(e) {
  if (e.key === 'Enter' && !e.shiftKey) {
    // 핵심: 한글 IME 조합 중(isComposing=true)이면 전송하지 않음
    // 이게 없으면 "하하하" → "하하" + "하" 2개 메시지로 쪼개짐
    if (e.isComposing || e.keyCode === 229) return;
    e.preventDefault();
    sendChatMessage();
  }
}