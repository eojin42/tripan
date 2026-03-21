/**
 * workspace.chat.js — 여행 워크스페이스 채팅
 * ─────────────────────────────────────────────
 * 의존: CTX_PATH, TRIP_ID, MY_MEMBER_ID, MY_NICK (workspace.jsp에서 주입)
 *       SockJS + STOMP (이미 로드됨)
 * ─────────────────────────────────────────────
 */

/* ══════════════════════════════════════════
   상태
══════════════════════════════════════════ */
var _chat = {
  roomId:       null,
  open:         false,
  loadingMore:  false,
  oldestMsgId:  null,
  stompSub:     null,
  unread:       0
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

      // 안 읽은 수 표시
      _setUnread(data.unreadCount || 0);

      // WebSocket 채팅 채널 구독
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

  _chat.open = true;
  modal.classList.add('open');
  _setUnread(0); // 즉시 배지 숨김

  // 메시지 로드 완료 후 읽음 처리 (로드 전 last_connected_at 갱신 방지)
  _chat.oldestMsgId = null;
  _loadMessages(null, true, function() {
    _markRead(); // 로드 완료 콜백에서 읽음 처리
  });
}

function _closeChat() {
  var modal = document.getElementById('chatModal');
  if (!modal) return;
  _chat.open = false;
  modal.classList.remove('open');
}

/* ══════════════════════════════════════════
   메시지 로드
══════════════════════════════════════════ */
function _loadMessages(beforeId, scrollToBottom, onComplete) {
  if (!_chat.roomId) return;
  _chat.loadingMore = true;

  var list = document.getElementById('chatMessageList');

  if (!beforeId && list) {
    list.innerHTML = '<div class="chat-loading-text">불러오는 중...</div>';
  }

  var url = CTX_PATH + '/api/trips/' + TRIP_ID + '/chat/messages?limit=50'
          + (beforeId ? '&beforeId=' + beforeId : '');

  fetch(url)
    .then(function(r) { return r.ok ? r.json() : []; })
    .then(function(msgs) {
      _chat.loadingMore = false;
      if (!list) return;

      var prevHeight = list.scrollHeight;

      if (!msgs.length) {
        if (!beforeId) {
          list.innerHTML = '<div class="chat-empty-text">아직 채팅 내역이 없습니다.<br>첫 번째 메시지를 보내보세요! 💬</div>';
        }
        if (typeof onComplete === 'function') onComplete();
        return;
      }

      var html = msgs.map(_buildMsgHtml).join('');

      if (beforeId) {
        list.insertAdjacentHTML('afterbegin', html);
        list.scrollTop = list.scrollHeight - prevHeight;
      } else {
        list.innerHTML = html;
      }

      if (msgs[0]) _chat.oldestMsgId = msgs[0].messageId;

      if (scrollToBottom) {
        list.scrollTop = list.scrollHeight;
      }

      if (typeof onComplete === 'function') onComplete();
    })
    .catch(function() {
      _chat.loadingMore = false;
      if (list && !beforeId) {
        list.innerHTML = '<div class="chat-empty-text">메시지를 불러오지 못했습니다.</div>';
      }
      if (typeof onComplete === 'function') onComplete();
    });
}

/* ══════════════════════════════════════════
   메시지 전송
══════════════════════════════════════════ */
function sendChatMessage() {
  var input = document.getElementById('chatInput');
  if (!input) return;
  var content = input.value.trim();
  if (!content) return;

  // IME 잔재로 끼어든 연속 개행 제거 (한글 조합 중 Enter로 생기는 \n 방어)
  content = content.replace(/\n+/g, ' ').trim();
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
      // 상대방 메시지: 항상 표시
      _appendMessage(msg, false);
    }
    // 내 메시지는 sendChatMessage() REST 응답에서 이미 추가했으므로 WS 수신 시 skip
    _markRead();
  } else {
    // 채팅창 닫혀있으면 배지 증가 (상대방 메시지만)
    if (!isMe) {
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
    ? ' style="background:' + color + ';color:#fff"'
    : '';

  return '<div class="chat-msg ' + side + '">'
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
    _loadMessages(_chat.oldestMsgId, false);
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